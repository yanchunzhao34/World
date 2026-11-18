"""Cold-start the real Editor in an isolated project and test Play/Stop/replay."""

import json
import os
import shutil
import socket
import statistics
import sys
import time
import uuid
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]


def main():
    # Keep the user's current editor world and preferences untouched.
    project = ROOT / "validation" / ("editor-project-" + uuid.uuid4().hex[:8])
    project.mkdir(parents=True)
    for folder in ("Assets", "Packages", "ProjectSettings"):
        shutil.copytree(ROOT / folder, project / folder,
                        ignore=shutil.ignore_patterns("__pycache__", ".infernux-engine-lock.json"))
    (project / "ProjectSettings/EditorSettings.json").write_text(json.dumps({
        "lastOpenedSceneGuid": "36c78d407f30845eba0dd74ba4cca4ba"}), encoding="utf-8")
    (project / "ProjectSettings/mcp_capabilities.json").write_text(
        json.dumps({"enabled": True, "profile": "developer_assist"}), encoding="utf-8")
    with socket.socket() as listener:
        listener.bind(("127.0.0.1", 0))
        os.environ["INFERNUX_MCP_PORT"] = str(listener.getsockname()[1])

    from infernux import resources
    from infernux.engine.library_sync import sync_resources
    from infernux.engine.bootstrap import EditorBootstrap
    from infernux.components.script_loader import get_script_errors
    from infernux.lib import InxGUIRenderable, LogLevel, SceneManager

    sync_resources(str(project))
    resources.activate_library(str(project))
    bootstrap = EditorBootstrap(str(project), LogLevel.Info)
    errors, report = [], {"project": str(project), "cycles": 0, "captures": [],
                          "performance_cycles": [], "audio_enabled": True,
                          "input_driver": "UI callbacks"}
    try:
        bootstrap.run()
        print("EDITOR_BOOTSTRAPPED", flush=True)
        frontend = bootstrap.engine
        native = frontend.get_native_engine()
        manager = frontend.get_play_mode_manager()
        assert not get_script_errors(), get_script_errors()
        native.set_editor_fps_cap(60)
        native.set_editor_idle_fps(0)
        previous_play_cap = native.get_play_fps_cap()
        started, phase, session, capture, ready = time.monotonic(), "enter", None, 0, 0
        frame_samples = []

        def after_draw():
            nonlocal phase, session, capture, ready
            try:
                now = time.monotonic()
                serious = [entry for entry in bootstrap.console._get_visible_log_snapshot(200)
                           if entry["level"] in ("ERROR", "FATAL")]
                assert not serious, serious
                if now - started > 90:
                    raise TimeoutError("Editor verification timed out in " + phase + ": " +
                                       repr((getattr(session, "ui", None), get_script_errors())))
                if phase == "enter":
                    assert manager.enter_play_mode()
                    phase = "ready"
                elif phase == "ready" and manager.is_playing:
                    scene = SceneManager.instance().get_active_scene()
                    owner = scene.find("Element Workshop").get_py_components()[0]
                    session = getattr(owner, "session", None)
                    if session is not None and not getattr(session, "_verification_logged", False):
                        session._verification_logged = True
                        original_update = session.presentation.update

                        def observe_update(frame, width, height):
                            original_update(frame, width, height)
                            sample_time = time.monotonic()
                            if (frame is not None and phase == "lab" and sample_time - ready > 3
                                    and frame.state["map"] == "lab"):
                                frame_samples.append((sample_time, frame.state["frame"],
                                    frame.state["frame_ms"], native.renderer_frame_snapshot["frame"]))

                        session.presentation.update = observe_update
                        print("EDITOR_SESSION_STARTED", scene.name, flush=True)
                    if session is None or not session.ui.current:
                        return
                    assert not session.ui.error, session.ui.error
                    assert session.ui.current["map"] == "titlelab"
                    assert session.ui.editor_panel.is_content_visible()
                    assert session.ui.dimensions[0] > 100
                    report["viewport"] = list(session.ui.dimensions)
                    print("EDITOR_UI_READY", session.ui.dimensions, flush=True)
                    # 0.4.8 synthetic gameplay input is separate from ImGui.
                    # Exercise the callbacks shared by the actual UI controls.
                    session.ui.start_game("lab")
                    phase, ready = "lab", now
                elif phase == "lab" and now - ready > 9:
                    assert session.ui.playing, "Game start callback did not complete"
                    assert not session.ui.error, session.ui.error
                    if session.ui.current["map"] != "lab":
                        return
                    assert len(frame_samples) > 30, frame_samples
                    elapsed = frame_samples[-1][0] - frame_samples[0][0]
                    intervals = sorted((b[0] - a[0]) * 1000
                                       for a, b in zip(frame_samples, frame_samples[1:]))
                    performance = dict(
                        seconds=elapsed, samples=len(frame_samples),
                        produced_fps=(frame_samples[-1][1] - frame_samples[0][1]) / elapsed,
                        engine_fps=(frame_samples[-1][3] - frame_samples[0][3]) / elapsed,
                        presentation_fps_cap=native.get_play_fps_cap(),
                        displayed_new_frames_per_second=(len(frame_samples) - 1) / elapsed,
                        mean_compute_ms=statistics.mean(row[2] for row in frame_samples),
                        mean_interval_ms=statistics.mean(intervals),
                        p95_interval_ms=intervals[int(len(intervals) * .95)],
                        maximum_interval_ms=max(intervals),
                    )
                    report["performance_cycles"].append(performance)
                    frame_samples.clear()
                    print("EDITOR_GAME_PERFORMANCE", json.dumps(performance), flush=True)
                    session.ui.toggle_pause()
                    phase, ready = "paused", now
                elif phase == "paused" and now - ready > .2:
                    if not session.ui.current["paused"]:
                        if now - ready > 5:
                            raise AssertionError(("Pause callback was not delivered", session.ui.paused))
                        return
                    report["pause_callback"] = True
                    print("EDITOR_PAUSE_CALLBACK_PASS", flush=True)
                    destination = ROOT / f"validation/editor-window-{report['cycles'] + 1}.png"
                    capture = frontend.request_capture("editor", str(destination))
                    phase = "capture"
                elif phase == "capture":
                    result = frontend.query_capture(capture)
                    if result.get("status") not in ("completed", "ready", "failed"):
                        return
                    assert result.get("status") != "failed", result
                    report["captures"].append(str(destination := ROOT / f"validation/editor-window-{report['cycles'] + 1}.png"))
                    assert destination.is_file()
                    assert manager.exit_play_mode()
                    phase = "stopped"
                elif phase == "stopped" and manager.is_edit_mode:
                    assert not session.runtime.thread.is_alive()
                    assert native.get_play_fps_cap() == previous_play_cap
                    logs = bootstrap.console._get_visible_log_snapshot(200)
                    serious = [entry for entry in logs if entry["level"] in ("ERROR", "FATAL")]
                    assert not serious, serious
                    report["cycles"] += 1
                    phase = "enter"
                    if report["cycles"] == 2:
                        report["passed"] = True
                        native.exit()
            except BaseException as error:
                errors.append(error)
                native.exit()

        class Driver(InxGUIRenderable):
            def on_render(self, ctx):
                after_draw()

        frontend.register_gui("Workshop Editor Verification", Driver(), priority=1000)
        native.show()
        frontend.run()
        if errors:
            raise errors[0]
        assert report.get("passed"), report
        (ROOT / "validation/editor-play.json").write_text(
            json.dumps(report, ensure_ascii=False, indent=2), encoding="utf-8")
        print("EDITOR_PLAY_STOP_REPLAY_PASS", flush=True)
    finally:
        if bootstrap.engine is not None:
            if bootstrap.engine.get_native_engine() is not None:
                bootstrap.engine.unregister_gui("Workshop Editor Verification")
            bootstrap.engine.exit()
        if report.get("passed"):
            target = project.resolve()
            assert target.parent == (ROOT / "validation").resolve()
            assert target.name.startswith("editor-project-")
            shutil.rmtree(target)


if __name__ == "__main__":
    main()
    sys.stdout.flush()
    sys.stderr.flush()
    os._exit(0)
