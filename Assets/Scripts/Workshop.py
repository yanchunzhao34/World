"""熔炉场景入口，独立启动器与编辑器组件共用同一运行会话。"""

from pathlib import Path

import infernux as inx
from infernux.application import Application
from infernux.lib import Vector3

from .native.game_runtime import GameRuntime
from .native.presentation import Presentation
from .native.sound_synth import SoundSynth
from .ui.workshop_ui import WorkshopUI


class WorkshopSession:
    # 初始化游戏会话及其持有的运行对象。
    def __init__(
        self,
        frontend,
        scene,
        root,
        user_directory,
        map_key=None,
        paused=False,
        editor_panel=None,
        scene_owned=False,
    ):
        self.frontend = frontend
        self.native = frontend.get_native_engine()
        self.runtime = None
        self.presentation = None
        self.ui = None
        self.previous_play_fps_cap = None
        self.play_fps_cap = None
        self.sound = SoundSynth()

        try:
            # 限制重复呈现的开销，为60Hz模拟与界面交互留出预算
            self.previous_play_fps_cap = self.native.get_play_fps_cap()

            if self.previous_play_fps_cap > 0:
                self.play_fps_cap = min(120, self.previous_play_fps_cap)

            else:
                self.play_fps_cap = 120

            self.native.set_play_fps_cap(self.play_fps_cap)

            camera = scene.effective_game_camera

            if camera is None:
                owner = scene.create_game_object("Workshop Camera")
                owner.transform.position = Vector3(0, 0, -5)

                owner.add_component("Camera")

            self.native.set_game_camera_enabled(True)

            self.presentation = Presentation(frontend, scene, root, scene_owned)
            self.runtime = GameRuntime(
                root / "Assets/Workshop",
                user_directory / "saves",
                map_key or "titlelab",
                paused,
            )
            self.ui = WorkshopUI(
                frontend,
                self.runtime,
                self.presentation,
                self.sound,
                root,
                user_directory,
                map_key,
                paused,
                editor_panel,
            )

            frontend.register_gui("Element Workshop", self.ui, priority=100)

            # 依赖就绪后再启动线程，避免半初始化会话继续运行
            self.runtime.start()

        except BaseException:
            self.close()

            raise

    # 结束游戏会话并恢复编辑器运行设置。
    def close(self):
        try:
            self.frontend.unregister_gui("Element Workshop")

            if self.runtime is not None:
                # 等待模拟线程退出，避免资源释放后后台继续访问GPU
                self.runtime.close()

            self.sound.close()

            if self.ui is not None:
                self.ui.close()

            if self.presentation is not None:
                self.presentation.close()

        finally:
            # 避免停止播放时覆盖编辑器刚调整的帧率设置
            if (
                self.previous_play_fps_cap is not None
                and self.native.get_play_fps_cap() == self.play_fps_cap
            ):
                self.native.set_play_fps_cap(self.previous_play_fps_cap)

            self.previous_play_fps_cap = None


class Workshop(inx.InxComponent):
    # 从场景组件创建共享游戏会话。
    def start(self):
        frontend = Application._current_engine()

        if frontend is None:
            raise RuntimeError("Workshop requires an active Infernux application")

        root = Path(Application.data_path())
        panel = None

        if Application.is_editor():
            from infernux.engine.ui.window_manager import WindowManager

            manager = WindowManager.instance()

            if manager is not None:
                panel = manager.open_window("game_view")

                manager.focus_window("game_view")

        self.session = WorkshopSession(
            frontend,
            self.game_object.scene,
            root,
            root / "UserData",
            editor_panel=panel,
            scene_owned=True,
        )

    # 将场景更新交给游戏界面与呈现接收端。
    def update(self, delta_time):
        session = getattr(self, "session", None)

        if session is not None:
            # 主线程继续处理纹理上传，模拟线程有新帧时再更新画面。
            session.ui.update()

    # 结束场景组件持有的游戏会话。
    def on_destroy(self):
        session = getattr(self, "session", None)

        if session is not None:
            session.close()

            # 清除旧会话引用，避免重复销毁和再次播放共用失效对象
            self.session = None
