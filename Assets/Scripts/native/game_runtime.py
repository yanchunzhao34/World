"""Action queue, Python simulation worker and immutable latest-frame mailbox."""

from _infernux_packages.workshop.runtime.library.dependencies import (
    base64,
    queue,
    threading,
    time,
    traceback,
)

from .python_core.runtime import Frame, Simulation
from .world_state_capture import WorldStateCapture, WorldSnapshotMailbox


# 将原始字节编码为兼容桥接接口的文本。
def encode_binary(data):
    """Retained for callers of the old binary utility API."""

    return base64.b64encode(data).decode("ascii")


# 还原兼容桥接接口中的二进制数据。
def decode_binary(text):
    return base64.b64decode(text, validate=True)


class GameRuntime:
    # 初始化后台运行器与线程通信状态。
    def __init__(self, assets, save_directory, map_key="titlelab", paused=False):
        self.actions = queue.SimpleQueue()
        self.errors = queue.SimpleQueue()

        # 邮箱只留最新画面，避免主线程消费积压旧帧
        self.frames = queue.Queue(maxsize=1)
        self.stop = threading.Event()
        self.arguments = assets, save_directory, map_key, paused
        self.world_snapshots = WorldSnapshotMailbox()
        self.thread = threading.Thread(
            target=self.run, name="Element Workshop GPU", daemon=True
        )

    # 启动独占模拟状态的后台线程。
    def start(self):
        self.thread.start()

    # 将界面操作交给后台模拟线程。
    def send_action(self, action):
        if not self.stop.is_set():
            self.actions.put(action)

    # 取得当前可用的最新游戏帧。
    def latest(self, timeout=0):
        try:
            if timeout > 0:
                return self.frames.get(timeout=timeout)

            else:
                return self.frames.get_nowait()

        except queue.Empty:
            return None

    # 执行模拟循环并交付画面、快照与错误。
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
                frame = simulation.frame(min(0.1, max(0.001, started - previous)))

                if requests:
                    try:
                        self.world_snapshots.complete(
                            requests, capture.capture(simulation)
                        )

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

    # 停止后台循环并等待GPU资源清理。
    def close(self):
        self.stop.set()
        self.world_snapshots.close()

        if self.thread.ident is not None:
            # 等待GPU清理完成，避免编辑器重播时资源交错
            self.thread.join()

    # 申请一份帧末世界观测快照。
    def RequestWorldSnapshot(self):
        return self.world_snapshots.request()

    # 查询世界快照请求的当前状态。
    def GetWorldSnapshotStatus(self, identifier):
        return self.world_snapshots.get(identifier)["status"]

    # 读取世界快照请求的失败原因。
    def GetWorldSnapshotError(self, identifier):
        return self.world_snapshots.get(identifier)["error"]

    # 读取已就绪世界快照的元数据。
    def GetWorldSnapshotMetadata(self, identifier):
        return self.ready_snapshot(identifier).metadata_json

    # 复制已就绪世界快照的指定字段。
    def CopyWorldSnapshotField(self, identifier, name):
        return self.ready_snapshot(identifier).copy_field_bytes(name)

    # 释放调用方持有的世界快照请求。
    def ReleaseWorldSnapshot(self, identifier):
        return self.world_snapshots.release(identifier)

    # 取得已就绪快照并校验请求状态。
    def ready_snapshot(self, identifier):
        request = self.world_snapshots.get(identifier)

        if request["status"] != "ready":
            raise RuntimeError("World snapshot is not ready")

        return request["snapshot"]
