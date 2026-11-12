"""Measure newly produced game frames, independently of the editor FPS counter."""

import argparse
import json
import statistics
import sys
import time
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
sys.path.insert(0, str(ROOT / "Assets/Scripts"))

from workshop_bootstrap import preload_dependencies

DEPENDENCIES = preload_dependencies(ROOT)

from native.game_runtime import GameRuntime, Simulation


def distribution(values):
    ordered = sorted(values)
    return dict(mean=statistics.mean(ordered), median=statistics.median(ordered),
                p95=ordered[min(len(ordered) - 1, int(len(ordered) * .95))],
                maximum=max(ordered))


def measure(args):
    assets, saves = ROOT / "Assets/Workshop", ROOT / "validation/performance-saves"
    sim = Simulation(assets, saves, args.map)
    try:
        for _ in range(30):
            sim.frame()
        frames = [sim.frame().state["frame_ms"] for _ in range(args.frames)]
        report = dict(map=args.map, adapter=dict(sim.host.adapter.info),
                      fixed_step=dict(samples=len(frames), frame_ms=distribution(frames)))
    finally:
        sim.close()

    runtime = GameRuntime(assets, saves, args.map)
    runtime.start()
    observations = []
    ready = None
    deadline = time.perf_counter() + 60
    try:
        while time.perf_counter() < deadline:
            if not runtime.errors.empty():
                raise RuntimeError(runtime.errors.get())
            frame = runtime.latest()
            now = time.perf_counter()
            if frame is not None:
                if ready is None:
                    ready = now
                # Warm up after the first actual frame, excluding shader compilation.
                if now - ready >= 2:
                    observations.append((now, frame.state["frame_ms"], frame.state["tick"]))
            if len(observations) > 1 and now - observations[0][0] >= args.seconds:
                break
            time.sleep(.001)
        else:
            raise TimeoutError("Runtime performance sampling timed out")
    finally:
        runtime.close()
    elapsed = observations[-1][0] - observations[0][0]
    report["realtime"] = dict(
        samples=len(observations), seconds=elapsed,
        new_frames_per_second=(len(observations) - 1) / elapsed,
        simulation_ticks_per_second=(observations[-1][2] - observations[0][2]) / elapsed,
        frame_ms=distribution([item[1] for item in observations]),
        interval_ms=distribution([(b[0] - a[0]) * 1000
                                  for a, b in zip(observations, observations[1:])]),
    )
    output = ROOT / args.output
    output.write_text(json.dumps(report, indent=2, ensure_ascii=False), encoding="utf-8")
    print(json.dumps(report, indent=2, ensure_ascii=False), flush=True)


if __name__ == "__main__":
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--map", default="lab")
    parser.add_argument("--frames", type=int, default=120)
    parser.add_argument("--seconds", type=float, default=5)
    parser.add_argument("--output", default="validation/performance-after.json")
    measure(parser.parse_args())
