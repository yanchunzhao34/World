"""使用现有熔炉 Python 3.13 启动项目，依赖仅从工程本地目录加载。"""

import argparse
import importlib.util
import os
import subprocess
import sys
import time
import traceback
from pathlib import Path

ROOT = Path(__file__).resolve().parent
sys.path[:0] = [str(ROOT / ".runtime/packages"), str(ROOT / "Assets")]


# 选择能够加载熔炉的Python运行环境。
def select_runtime():
    if importlib.util.find_spec("infernux") is not None:
        # 复用已具备熔炉依赖的解释器，避免重复拉起进程
        return

    configured = os.environ.get("INFERNUX_PYTHON")
    candidates = [Path(configured)] if configured else []
    candidates += [ROOT / ".runtime/python313/python.exe"]
    candidates += sorted(ROOT.parent.glob("*/.runtime/python313/python.exe"))

    for candidate in candidates:
        if (
            candidate.is_file()
            and candidate.resolve() != Path(sys.executable).resolve()
        ):
            result = subprocess.run(
                [str(candidate), str(ROOT / "launch.py"), *sys.argv[1:]],
                cwd=ROOT,
                env={**os.environ, "PYTHONIOENCODING": "utf-8"},
            )

            raise SystemExit(result.returncode)

    raise RuntimeError("没有找到熔炉 Python 3.13 环境。请设置 INFERNUX_PYTHON。")


# 为游戏窗口建立兼容的高DPI上下文。
def configure_windows_dpi():
    """在 SDL 创建窗口前建立 PMv2，兼容父启动器继承的 DPI 设置。"""

    if sys.platform != "win32":
        return

    import ctypes
    from ctypes import wintypes

    user32 = ctypes.WinDLL("user32", use_last_error=True)
    user32.GetThreadDpiAwarenessContext.argtypes = []
    user32.GetThreadDpiAwarenessContext.restype = ctypes.c_void_p
    user32.AreDpiAwarenessContextsEqual.argtypes = [ctypes.c_void_p, ctypes.c_void_p]
    user32.AreDpiAwarenessContextsEqual.restype = wintypes.BOOL
    user32.SetProcessDpiAwarenessContext.argtypes = [ctypes.c_void_p]
    user32.SetProcessDpiAwarenessContext.restype = wintypes.BOOL
    user32.SetThreadDpiAwarenessContext.argtypes = [ctypes.c_void_p]
    user32.SetThreadDpiAwarenessContext.restype = ctypes.c_void_p

    per_monitor_v2 = ctypes.c_void_p(-4)

    if user32.AreDpiAwarenessContextsEqual(
        user32.GetThreadDpiAwarenessContext(), per_monitor_v2
    ):
        return

    if not user32.SetProcessDpiAwarenessContext(per_monitor_v2):
        # 父启动器可能锁定进程策略，窗口线程需单独覆盖DPI设置
        if not user32.SetThreadDpiAwarenessContext(per_monitor_v2):
            raise ctypes.WinError(ctypes.get_last_error())

    if not user32.AreDpiAwarenessContextsEqual(
        user32.GetThreadDpiAwarenessContext(), per_monitor_v2
    ):
        raise RuntimeError("无法为游戏窗口建立 Per-Monitor V2 DPI 上下文。")


# 启动原生游戏窗口并管理运行会话。
def main():
    select_runtime()
    configure_windows_dpi()

    import infernux as inx
    from Infernux.lib import SceneManager, ConsolePanel
    from tools.workshop_bootstrap import preload_dependencies

    dependencies = preload_dependencies(ROOT)

    from Scripts.Workshop import WorkshopSession
    from Scripts.ui.workshop_ui import WorkshopUI
    from PIL import Image
    import numpy as np

    parser = argparse.ArgumentParser(description=__doc__)

    parser.add_argument("--map", choices=WorkshopUI.MAPS + ["titlelab"])
    parser.add_argument("--paused", action="store_true")
    parser.add_argument("--smoke", action="store_true")
    parser.add_argument("--ui-smoke", action="store_true")
    parser.add_argument("--width", type=int, default=1280)
    parser.add_argument("--height", type=int, default=720)

    args = parser.parse_args()
    frontend = inx.Engine()
    native = frontend.get_native_engine()
    session = None
    errors, completed = [], False

    # 验证运行隔离用户目录，避免覆盖玩家进度与存档
    user_directory = ROOT / (
        "validation/ui-user" if args.smoke or args.ui_smoke else "UserData"
    )

    try:
        frontend.init_renderer(args.width, args.height, str(ROOT))
        frontend.resize_game_render_target(args.width, args.height)
        native.set_window_title("元素工坊 · 熔炉")
        native.set_editor_fps_cap(60)
        native.set_editor_idle_fps(0)
        native.set_gui_font(
            str(Path(os.environ.get("WINDIR", r"C:\Windows")) / "Fonts/msyh.ttc"), 16
        )

        scene = SceneManager.instance().get_active_scene()

        for obj in scene.get_root_objects():
            scene.destroy_game_object(obj)

        session = WorkshopSession(
            frontend, scene, ROOT, user_directory, args.map, args.paused
        )
        ui = session.ui
        console = ConsolePanel()
        started, ready_at = time.monotonic(), None
        ticket, phase, phase_started = None, 0, 0

        if args.ui_smoke:
            captures = ["home", "hud", "library", "codex", "settings"]

        else:
            captures = ["game"]

        # 处理窗口退出与原生界面验证进度。
        def after_draw():
            nonlocal completed, ready_at, ticket, phase, phase_started

            try:
                database = frontend.get_asset_database()

                if database.refresh_pending:
                    database.try_commit_refresh()

                if native.is_close_requested():
                    native.confirm_close()
                    native.exit()

                if ui.error:
                    raise RuntimeError(ui.error)

                if not (args.smoke or args.ui_smoke):
                    return

                now = time.monotonic()

                if now - started > 90:
                    raise TimeoutError("Native UI smoke test timed out")

                if ui.current and ready_at is None:
                    ready_at, phase_started = now, now

                if ready_at is None or now - phase_started < 2:
                    return

                if ticket is None:
                    ticket = frontend.request_render_target_readback(True)

                elif ticket.done:
                    pixels = ticket.result_numpy()
                    rgb = np.clip(pixels[..., :3] * 255, 0, 255).astype(np.uint8)

                    (ROOT / "validation").mkdir(exist_ok=True)
                    Image.fromarray(rgb).save(
                        ROOT
                        / f"validation/infernux-render-{captures[phase]}-{args.width}.png"
                    )
                    print(
                        "NATIVE_UI_STATE_RENDERED",
                        captures[phase],
                        pixels.shape,
                        flush=True,
                    )

                    phase += 1

                    if phase == len(captures):
                        engine_errors = [
                            entry
                            for entry in console._get_visible_log_snapshot(1000)
                            if entry["level"] in ("ERROR", "FATAL")
                        ]

                        if engine_errors:
                            raise RuntimeError(str(engine_errors))

                        completed = True

                        native.exit()

                    else:
                        if captures[phase] == "hud":
                            ui.start_game("lab")

                        else:
                            ui.open_modal(captures[phase])

                        ticket, phase_started = None, now

            except BaseException as error:
                errors.append(error)
                native.exit()

        native.set_post_draw_callback(after_draw)

        if not (args.smoke or args.ui_smoke):
            native.show()

        native.run()

        if errors:
            raise errors[0]

        if (args.smoke or args.ui_smoke) and not completed:
            raise RuntimeError("Native renderer exited before verification completed")

    finally:
        native.set_post_draw_callback(None)

        if session:
            session.close()

        frontend.exit()

    print("INFERNUX_EXIT_OK", flush=True)


if __name__ == "__main__":
    try:
        main()

    except Exception:
        traceback.print_exc()

        raise SystemExit(1)

    # 按播放器约定直接退出，避免GUI对象在解释器清理期析构
    sys.stdout.flush()
    sys.stderr.flush()
    os._exit(0)
