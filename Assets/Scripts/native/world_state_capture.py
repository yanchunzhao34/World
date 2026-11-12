"""按需帧末观测，保留 v1 字段、布局、容量及不可变数据约定。"""

import json
import math
from dataclasses import dataclass
from _infernux_packages.workshop.runtime.library.dependencies import threading, uuid, MappingProxyType

import numpy as np


@dataclass(frozen=True)
class WorldStateSnapshot:
    metadata_json: str
    fields: object

    def copy_field_bytes(self, name):
        return bytes(bytearray(self.fields[name]))


class WorldStateCapture:
    def __init__(self):
        self.session_id = uuid.uuid4().hex
        self.sequence = 0

    def capture(self, simulation):
        metadata = json.loads(simulation.call("describeWorldObservation"))
        if metadata["schema_version"] != 1:
            raise ValueError("Unsupported world observation schema")
        fields, descriptors = {}, []
        for resource in metadata.pop("gpu_resources"):
            descriptor = {key: resource[key] for key in ("name", "dtype", "shape", "unit", "encoding")}
            expected = math.prod(resource["shape"]) * np.dtype(resource["dtype"]).itemsize
            if resource["kind"] == "texture":
                value = simulation.host.read_texture(resource["id"])
            elif resource["kind"] == "buffer":
                value = simulation.host.read_buffer(resource["id"], 0, expected)
            else:
                # A restored save can have a different background than its source map.
                from .game_runtime import decode_binary
                value = decode_binary(simulation.evaluate("byteString(app.currentBackground)"))
            if len(value) != expected:
                raise ValueError("World observation layout mismatch for " + resource["name"])
            fields[resource["name"]] = value
            descriptor["byte_length"] = len(value)
            descriptors.append(descriptor)
        packed = np.frombuffer(fields["cells_packed"], "<u4").reshape(288, 512, 4)
        fields["material_id"] = (packed[..., 0] & 255).astype("uint8").tobytes()
        fields["temperature_kelvin"] = packed[..., 1].copy().tobytes()
        for name, dtype, unit in (("material_id", "uint8", "material_table_index"),
                                   ("temperature_kelvin", "float32", "kelvin")):
            descriptors.append(dict(name=name, dtype=dtype, shape=[288, 512], unit=unit,
                                    encoding="dense", byte_length=len(fields[name])))
        self.sequence += 1
        metadata.update(runtime_session_id=self.session_id, snapshot_sequence=self.sequence,
                        byte_order="little_endian", fields=descriptors)
        return WorldStateSnapshot(json.dumps(metadata, ensure_ascii=False), MappingProxyType(fields))


class WorldSnapshotMailbox:
    def __init__(self):
        self.lock, self.requests = threading.Lock(), {}
        self.next_id, self.stopped = 1, False

    def request(self):
        with self.lock:
            if self.stopped or len(self.requests) >= 2:
                return -1
            identifier = self.next_id
            self.next_id += 1
            self.requests[identifier] = dict(status="pending", snapshot=None, error="")
            return identifier

    def take_pending(self):
        with self.lock:
            pending = [key for key, value in self.requests.items() if value["status"] == "pending"]
            for key in pending:
                self.requests[key]["status"] = "capturing"
            return pending

    def complete(self, identifiers, snapshot=None, error=""):
        with self.lock:
            for identifier in identifiers:
                if identifier in self.requests:
                    self.requests[identifier].update(status="failed" if error else "ready",
                                                     snapshot=snapshot, error=error)

    def get(self, identifier):
        with self.lock:
            return dict(self.requests.get(identifier, dict(status="unknown", snapshot=None, error="")))

    def release(self, identifier):
        with self.lock:
            return self.requests.pop(identifier, None) is not None

    def close(self):
        with self.lock:
            self.stopped = True
            for request in self.requests.values():
                if request["status"] in ("pending", "capturing"):
                    request.update(status="failed", error="Runtime stopped")
