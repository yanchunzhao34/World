"""从熔炉 BuildSettings 加载场景，通过组件 Start 运行完整入口。"""

import sys
import time
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
sys.path[:0] = [str(ROOT / ".runtime/packages"), str(ROOT / "Assets"), str(ROOT / "Assets/Scripts")]

import infernux as inx
from infernux.lib import SceneManager, ConsolePanel
from workshop_bootstrap import preload_dependencies
DEPENDENCIES = preload_dependencies(ROOT)


def main():
    frontend = inx.Engine()
    native = frontend.get_native_engine()
    owner = None
    completed, errors = False, []
    try:
        frontend.init_renderer(960, 640, str(ROOT))
        frontend.resize_game_render_target(960, 640)
        console = ConsolePanel()
        assert inx.SceneManager.load_scene(0), "Scene load failed"
        scene = SceneManager.instance().get_active_scene()
        owner = scene.find("Element Workshop").get_py_components()[0]
        SceneManager.instance().play()
        started = time.monotonic()
        def after_draw():
            nonlocal completed
            try:
                database = frontend.get_asset_database()
                if database.refresh_pending:
                    database.try_commit_refresh()
                session = getattr(owner, "session", None)
                if session is not None and session.ui.current:
                    assert not session.ui.error, session.ui.error
                    assert session.ui.current["map"] == "titlelab"
                    serious = [entry for entry in console._get_visible_log_snapshot(1000)
                               if entry["level"] in ("ERROR", "FATAL")]
                    assert not serious, serious
                    completed = True
                    native.exit()
                if time.monotonic() - started > 40:
                    raise TimeoutError("Scene component startup timed out")
            except BaseException as error:
                errors.append(error)
                native.exit()
        native.set_post_draw_callback(after_draw)
        native.run()
        if errors:
            raise errors[0]
        assert completed
        print("SCENE_START_PASS", flush=True)
    finally:
        native.set_post_draw_callback(None)
        if owner is not None:
            owner.on_destroy()
        inx.compute._release_engine_resources()
        native.cleanup()


if __name__ == "__main__":
    main()
