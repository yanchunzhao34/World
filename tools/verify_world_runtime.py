"""通过后台线程验证快照容量、取消、复制与停止边界。"""

import json
import sys
import time
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
sys.path[:0] = [str(ROOT / ".runtime/packages"), str(ROOT / "Assets/Scripts")]

from workshop_bootstrap import preload_dependencies
DEPENDENCIES = preload_dependencies(ROOT)

from native.game_runtime import GameRuntime
from native.sound_synth import SoundSynth


def wait(runtime, identifier):
    until = time.monotonic() + 30
    while runtime.GetWorldSnapshotStatus(identifier) in ("pending", "capturing"):
        if time.monotonic() > until:
            raise TimeoutError("World observation timed out")
        if not runtime.errors.empty():
            raise RuntimeError(runtime.errors.get())
        time.sleep(.01)
    assert runtime.GetWorldSnapshotStatus(identifier) == "ready", runtime.GetWorldSnapshotError(identifier)
    return json.loads(runtime.GetWorldSnapshotMetadata(identifier))


def main():
    runtime = GameRuntime(ROOT / "Assets/Workshop", ROOT / "validation/thread-saves", "empty", True)
    runtime.start()
    results = {}
    try:
        first, second = runtime.RequestWorldSnapshot(), runtime.RequestWorldSnapshot()
        assert 0 < first < second and runtime.RequestWorldSnapshot() == -1
        results["capacity_two"] = True
        metadata = wait(runtime, first)
        other = wait(runtime, second)
        assert metadata == other and len(metadata["fields"]) == 15
        results["same_frame_shared_observation"] = True
        cells = runtime.CopyWorldSnapshotField(first, "cells_packed")
        copy = bytearray(runtime.CopyWorldSnapshotField(first, "material_id"))
        original = copy[0]
        copy[0] ^= 255
        assert runtime.CopyWorldSnapshotField(first, "material_id")[0] == original
        results["immutable_copy"] = True
        assert runtime.ReleaseWorldSnapshot(second)
        runtime.send_action(dict(type="load", map="lab"))
        third = runtime.RequestWorldSnapshot()
        changed = wait(runtime, third)
        assert changed["boundary"]["world_epoch"] > metadata["boundary"]["world_epoch"]
        assert changed["runtime_session_id"] == metadata["runtime_session_id"]
        assert runtime.CopyWorldSnapshotField(first, "cells_packed") == cells
        results["epoch_and_held_snapshot"] = True
        assert runtime.ReleaseWorldSnapshot(third)
        cancelled = runtime.RequestWorldSnapshot()
        assert runtime.ReleaseWorldSnapshot(cancelled)
        time.sleep(.2)
        assert runtime.GetWorldSnapshotStatus(cancelled) == "unknown"
        results["cancel_does_not_resurrect"] = True
        runtime.ReleaseWorldSnapshot(first)
    finally:
        runtime.close()
    assert runtime.RequestWorldSnapshot() == -1
    results["stopped_rejects_requests"] = True
    synth = SoundSynth()
    synth.update(dict(events=[400, 100, 0, 15, 144], paused=False, explosions=[[0, 0, 10, 1]]))
    samples = synth.generate(4410)
    assert len(samples) == 4410 * 4 and any(samples)
    results["audio_pcm_generation"] = True
    (ROOT / "validation/world-runtime.json").write_text(json.dumps(results, indent=2), "utf-8")
    print("WORLD_RUNTIME_PASS", json.dumps(results), flush=True)


if __name__ == "__main__":
    main()
