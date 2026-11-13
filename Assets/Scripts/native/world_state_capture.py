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
        # 显式复制字节，满足字段复制接口独立持有数据的约定
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
                # 存档可改写背景，观测应取当前内容以免回读原地图
                value = simulation.read_cpu_field(resource['name'])
            # 核对描述与字节数，避免错误布局被解读为合法状态
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
        # 只读字段映射配合独立字节，允许多个请求共用同帧快照
        return WorldStateSnapshot(json.dumps(metadata, ensure_ascii=False), MappingProxyType(fields))


class WorldSnapshotMailbox:
    def __init__(self):
        self.lock, self.requests = threading.Lock(), {}
        self.next_id, self.stopped = 1, False

    def request(self):
        with self.lock:
            # 限制同时持有的快照数量，避免大网格读回导致内存失控
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
                # 请求可能在采集期间被取消，发布前复查可避免结果复活
                if identifier in self.requests:
                    self.requests[identifier].update(status="failed" if error else "ready",
                                                     snapshot=snapshot, error=error)

    def get(self, identifier):
        with self.lock:
            # 返回状态副本，避免调用方绕过锁改写请求状态
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
