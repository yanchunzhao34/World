"""操作队列 → 单独模拟线程 → 最新帧邮箱，保留原运行时边界。"""

import json
from dataclasses import dataclass
from pathlib import Path

import numpy as np

from _infernux_packages.workshop.runtime.library.dependencies import (
    base64, queue, threading, time, traceback, quickjs,
)

from .gpu_host import GpuHost
from .world_state_capture import WorldStateCapture, WorldSnapshotMailbox


BRIDGE = r"""
function byteString(value) {
    const data = value instanceof ArrayBuffer ? new Uint8Array(value) :
        new Uint8Array(value.buffer, value.byteOffset, value.byteLength);
    // QuickJS-NG implements this in native code and respects typed-array views.
    // ASCII also avoids the binding's NUL and concatenation-rope limitations.
    return data.toBase64();
}
function arrayBuffer(text) {
    return Uint8Array.fromBase64(text).buffer;
}
const host = {
    MakeTexture: __MakeTexture, MakeBuffer: __MakeBuffer, MakeSampler: __MakeSampler,
    Begin() {}, Flush: __Flush, ClearTexture: __ClearTexture, ClearBuffer: __ClearBuffer,
    CopyTexture: __CopyTexture, Destroy: __Destroy, LoadShader: __LoadShader,
    UploadBuffer(id, offset, data) { __UploadBuffer(id, offset, byteString(data)); },
    UploadTexture(id, data) { __UploadTexture(id, byteString(data)); },
    ReadBuffer(id, offset, size) { return arrayBuffer(__ReadBuffer(id, offset, size)); },
    ReadTexture(id, x, y, w, h, stride) {
        return arrayBuffer(__ReadTexture(id, x, y, w, h, stride));
    },
    ReadFile(path) { return arrayBuffer(__ReadFile(path)); },
    Dispatch(path, bindings, parameters, x, y, z) {
        __Dispatch(path, JSON.stringify(Array.from(bindings)), byteString(parameters), x, y, z);
    },
    SaveState(map, time, cells, background) {
        __SaveState(map, time, byteString(cells), byteString(background));
    },
    LoadSavedInfo: __LoadSavedInfo,
    LoadSavedCells() { return arrayBuffer(__LoadSavedCells()); },
    LoadSavedBackground() { return arrayBuffer(__LoadSavedBackground()); }
};
"""

# Adapt only the packed occupancy expansion; the original update still owns
# frame advancement, callbacks, collision solving and the GPU exchange packet.
# NumPy expands four two-bit cells per byte using a 256-entry lookup table.
OCCUPANCY_KERNEL = r"""
const workshopOriginalRigidUpdate = RigidBodyWorld.prototype.update;
RigidBodyWorld.prototype.update = function(delta, paused) {
    const packed = this.occIn;
    if (packed && this.w % 16 === 0 && packed.byteLength * 4 === this.occ.byteLength) {
        const expanded = arrayBuffer(__ExpandOccupancy(byteString(packed)));
        this.occ.set(new Uint8Array(expanded));
        this.occIn = null;
        this.haveOcc = true;
    }
    return workshopOriginalRigidUpdate.call(this, delta, paused);
};
"""


FRAME_READBACK = r"""
const workshopOriginalRender = WorldRenderer.prototype.render;
WorldRenderer.prototype.render = function(...args) {
    const result = workshopOriginalRender.apply(this, args);
    // All simulation and display writes are now encoded. Copy their results in
    // this same submission; the original synchronous callbacks keep their order.
    if (this === app.render) {
        const output = this.mode === 0 ? this.output : this.debugOutput;
        __QueueFrameReadbacks(app.sim.statsBuf.id, SimulationStatistics.SizeBytes,
            app.bodyGpu.occ.id, app.W * app.H / 4,
            app.bodyGpu.owner.id, app.bodyGpu.atlasUsed * 4, output.id);
    }
    return result;
};
"""


def encode_binary(data):
    return base64.b64encode(data).decode("ascii")


def decode_binary(text):
    return base64.b64decode(text, validate=True)


@dataclass(frozen=True)
class Frame:
    pixels: bytes
    width: int
    height: int
    state: dict


class Simulation:
    """仅由创建它的线程访问，包括验证工具。"""

    def __init__(self, assets, save_directory, map_key="titlelab", paused=False, *, lighting_corrections=True):
        self.host = GpuHost(assets, save_directory, lighting_corrections=lighting_corrections)
        self.js = quickjs.Context()
        self.js.set_memory_limit(512 * 1024 * 1024)
        self.js.set_max_stack_size(1024 * 1024)
        self.occupancy_table = ((np.arange(256, dtype=np.uint8)[:, None] >>
                                np.array([0, 2, 4, 6], dtype=np.uint8)) & 3)
        self.last_host_error = None
        methods = {
            "MakeTexture": self.host.make_texture, "MakeBuffer": self.host.make_buffer,
            "MakeSampler": self.host.make_sampler, "Flush": self.host.flush,
            "ClearTexture": self.host.clear_texture, "ClearBuffer": self.host.clear_buffer,
            "CopyTexture": self.host.copy_texture, "Destroy": self.host.destroy,
            "LoadShader": self.host.load_shader,
            "UploadBuffer": lambda i, o, b: self.host.upload_buffer(i, o, decode_binary(b)),
            "UploadTexture": lambda i, b: self.host.upload_texture(i, decode_binary(b)),
            "ReadBuffer": lambda i, o, s: encode_binary(self.host.read_buffer(i, o, s)),
            "ReadTexture": lambda *a: encode_binary(self.host.read_texture(*a)),
            "ReadFile": lambda p: encode_binary(self.host.read_file(p)),
            "Dispatch": lambda p, b, u, x, y, z: self.host.dispatch(
                p, json.loads(b), decode_binary(u), x, y, z),
            "SaveState": lambda m, t, c, b: self.host.save_state(
                m, t, decode_binary(c), decode_binary(b)),
            "LoadSavedInfo": self.host.load_saved_info,
            "LoadSavedCells": lambda: encode_binary(self.host.saved["cells.bin"]),
            "LoadSavedBackground": lambda: encode_binary(self.host.saved["background.bin"]),
            "QueueFrameReadbacks": self.host.queue_frame_readbacks,
            "ExpandOccupancy": self.expand_occupancy,
        }
        for name, method in methods.items():
            self.js.add_callable("__" + name, self.checked(method))
        try:
            self.js.eval(BRIDGE)
            self.js.set("gameJson", (Path(assets) / "original/data/game.json").read_text("utf-8"))
            for name in ("platform.js", "original_core.js", "demos.js", "world_observation.js", "lighting.js", "game.js"):
                if name == "game.js":
                    if lighting_corrections:
                        self.evaluate("registerLightingOcclusion();")
                    self.host.metadata = json.loads(self.js.eval("JSON.stringify(Ne)"))
                self.evaluate((Path(assets) / "runtime" / name).read_text("utf-8"))
            if lighting_corrections:
                self.evaluate("installLightingOcclusion(app.render);")
            self.evaluate(OCCUPANCY_KERNEL)
            self.evaluate(FRAME_READBACK)
            self.call("loadMap", map_key)
            self.action(dict(type="pause", value=paused))
        except BaseException:
            self.host.close()
            raise

    def checked(self, method):
        def invoke(*args):
            try:
                return method(*args)
            except BaseException as error:
                self.last_host_error = error
                raise
        return invoke

    def expand_occupancy(self, encoded):
        packed = np.frombuffer(decode_binary(encoded), dtype=np.uint8)
        return encode_binary(self.occupancy_table[packed].tobytes())

    def evaluate(self, source):
        try:
            return self.js.eval(source)
        except BaseException:
            if self.last_host_error is not None:
                error, self.last_host_error = self.last_host_error, None
                raise error
            raise

    def call(self, function, *args):
        return self.evaluate(function + "(" + ",".join(json.dumps(a) for a in args) + ")")

    def action(self, action):
        self.call("applyAction", json.dumps(action, ensure_ascii=False))

    def frame(self, delta=1 / 60, forced_ticks=-1):
        started = time.perf_counter()
        state = json.loads(self.call("nativeFrame", delta, forced_ticks))
        # Native Promise jobs deliver occupancy/owner callbacks after each frame's
        # explicit microtask queue, before accepting the next frame's actions.
        while self.js.execute_pending_job():
            pass
        pixels = self.host.read_texture(state["texture"])
        state["frame_ms"] = (time.perf_counter() - started) * 1000
        state["dispatches"] = self.host.dispatches
        return Frame(pixels, state["width"], state["height"], state)

    def close(self):
        self.host.close()
        self.js.gc()


class GameRuntime:
    def __init__(self, assets, save_directory, map_key="titlelab", paused=False):
        self.actions = queue.SimpleQueue()
        self.errors = queue.SimpleQueue()
        self.frames = queue.Queue(maxsize=1)
        self.stop = threading.Event()
        self.arguments = assets, save_directory, map_key, paused
        self.world_snapshots = WorldSnapshotMailbox()
        self.thread = threading.Thread(target=self.run, name="Element Workshop GPU", daemon=True)

    def start(self):
        self.thread.start()

    def send_action(self, action):
        if not self.stop.is_set():
            self.actions.put(action)

    def latest(self, timeout=0):
        try:
            return self.frames.get(timeout=timeout) if timeout > 0 else self.frames.get_nowait()
        except queue.Empty:
            return None

    def run(self):
        simulation = None
        try:
            simulation = Simulation(*self.arguments)
            capture = WorldStateCapture()
            previous = time.perf_counter()
            deadline = previous
            while not self.stop.is_set():
                started = time.perf_counter()
                requests = self.world_snapshots.take_pending()
                simulation.call("setWorldObservationEnabled", bool(requests))
                while not self.actions.empty():
                    try:
                        simulation.action(self.actions.get())
                    except Exception:
                        self.errors.put(traceback.format_exc())
                frame = simulation.frame(min(.1, max(.001, started - previous)))
                if requests:
                    try:
                        self.world_snapshots.complete(requests, capture.capture(simulation))
                    except Exception as error:
                        self.world_snapshots.complete(requests, error=str(error))
                previous = started
                if self.frames.full():
                    self.latest()
                self.frames.put_nowait(frame)
                # Fixed deadlines prevent each wait's overshoot accumulating.
                # Python's Windows sleep uses a high-resolution waitable timer;
                # Event.wait can round short waits to the system timer tick.
                deadline += 1 / 60
                now = time.perf_counter()
                if deadline < now - 1 / 60:
                    deadline = now
                remaining = deadline - now
                if remaining > 0 and not self.stop.is_set():
                    time.sleep(remaining)
        except BaseException:
            self.errors.put(traceback.format_exc())
        finally:
            self.world_snapshots.close()
            if simulation is not None:
                simulation.close()

    def close(self):
        self.stop.set()
        self.world_snapshots.close()
        if self.thread.ident is not None:
            self.thread.join()

    def RequestWorldSnapshot(self):
        return self.world_snapshots.request()

    def GetWorldSnapshotStatus(self, identifier):
        return self.world_snapshots.get(identifier)["status"]

    def GetWorldSnapshotError(self, identifier):
        return self.world_snapshots.get(identifier)["error"]

    def GetWorldSnapshotMetadata(self, identifier):
        return self.ready_snapshot(identifier).metadata_json

    def CopyWorldSnapshotField(self, identifier, name):
        return self.ready_snapshot(identifier).copy_field_bytes(name)

    def ReleaseWorldSnapshot(self, identifier):
        return self.world_snapshots.release(identifier)

    def ready_snapshot(self, identifier):
        request = self.world_snapshots.get(identifier)
        if request["status"] != "ready":
            raise RuntimeError("World snapshot is not ready")
        return request["snapshot"]
