"""Action queue, Python simulation worker and immutable latest-frame mailbox."""

from _infernux_packages.workshop.runtime.library.dependencies import (
    base64, queue, threading, time, traceback,
)

from .python_core.runtime import Frame, Simulation
from .world_state_capture import WorldStateCapture, WorldSnapshotMailbox


def encode_binary(data):
    """Retained for callers of the old binary utility API."""
    return base64.b64encode(data).decode("ascii")


def decode_binary(text):
    return base64.b64decode(text, validate=True)


class GameRuntime:
    def __init__(self, assets, save_directory, map_key="titlelab", paused=False):
        self.actions = queue.SimpleQueue()
        self.errors = queue.SimpleQueue()
        # 邮箱只留最新画面，避免主线程消费积压旧帧
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
            # 在工作线程创建模拟对象，集中GPU与世界状态的所有权
            simulation = Simulation(*self.arguments)
            capture = WorldStateCapture()
            previous = time.perf_counter()
            deadline = previous
            while not self.stop.is_set():
                started = time.perf_counter()
                requests = self.world_snapshots.take_pending()
                # 按需记录观测轨迹，减少正常游玩的复制开销
                simulation.call("setWorldObservationEnabled", bool(requests))
                while not self.actions.empty():
                    try:
                        simulation.action(self.actions.get())
                    except Exception:
                        self.errors.put(traceback.format_exc())
                # 限制异常时间差，避免窗口阻塞后模拟跨越过大时间
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
                # 按固定截止时刻调度，避免Windows短等待误差逐帧累积
                deadline += 1 / 60
                now = time.perf_counter()
                if deadline < now - 1 / 60:
                    # 丢弃过期等待，避免持续落后目标帧率
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
            # 等待GPU清理完成，避免编辑器重播时资源交错
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
