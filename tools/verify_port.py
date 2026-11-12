"""通过真实 GPU 和原操作入口检查移植回归，可重复运行。"""

import argparse
import hashlib
import json
import sys
import time
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
sys.path[:0] = [str(ROOT / ".runtime/packages"), str(ROOT / "Assets/Scripts")]

from workshop_bootstrap import preload_dependencies
DEPENDENCIES = preload_dependencies(ROOT)

import numpy as np
from PIL import Image
from native.game_runtime import Simulation
from ui.discovery_codex import DiscoveryCodex


def verify(args):
    results = {}
    results['renderer'] = 'original' if args.original_renderer else 'occlusion-corrected'
    output_directory = ROOT / 'validation/lighting'
    output_directory.mkdir(exist_ok=True)
    manifest = json.loads((ROOT / "source-manifest.json").read_text("utf-8"))
    for entry in manifest["files"]:
        assert hashlib.sha256((ROOT / entry["file"]).read_bytes()).hexdigest() == entry["sha256"], entry["file"]
    results["unchanged_source_files"] = len(manifest["files"])
    data = json.loads((ROOT / "Assets/Workshop/original/data/game.json").read_text("utf-8"))
    codex = DiscoveryCodex(data)
    assert len(data["materials"]) == 90 and len(data["reactions"]) == 44
    assert len(codex.entries) == 100
    results["catalog"] = dict(materials=90, reactions=44, discoveries=100)
    sim = Simulation(ROOT / "Assets/Workshop", ROOT / "validation/test-saves", "lab", True,
                     lighting_corrections=not args.original_renderer)
    try:
        results["adapter"] = dict(sim.host.adapter.info)
        if args.compare:
            for index in range(120):
                frame = sim.frame()
            output = output_directory / (results['renderer'] + '-fixed-lab.png')
            Image.frombytes("RGBA", (frame.width, frame.height), frame.pixels).save(output)
            current_reference = ROOT / "validation/godot-lab-reference.png"
            reference = Image.open(current_reference if current_reference.exists() else
                Path(manifest["source"]) / "validation/render_comparison/godot.png").convert("RGB")
            actual = np.frombuffer(frame.pixels, np.uint8).reshape(frame.height, frame.width, 4)[..., :3]
            delta = np.abs(actual.astype(np.int16) - np.asarray(reference).astype(np.int16))
            results["fixed_lab_comparison"] = dict(frames=120, width=frame.width, height=frame.height,
                rgb_mae=float(delta.mean()), rgb_p99=float(np.percentile(delta, 99)),
                rgb_max=int(delta.max()), channels_within_1=float((delta <= 1).mean()))
            print("COMPARISON", results["fixed_lab_comparison"], flush=True)
        if args.maps:
            results["maps"] = {}
            for key in ("lab", "cave", "volcano", "gallery", "optics", "energy", "cover", "empty", "titlelab"):
                sim.action(dict(type="load", map=key))
                sim.action(dict(type="pause", value=False))
                start = time.perf_counter()
                for _ in range(12):
                    frame = sim.frame()
                assert frame.state["map"] == key and frame.state["tick"] >= 12
                Image.frombytes("RGBA", (frame.width, frame.height), frame.pixels).save(output_directory / f"{results['renderer']}-{key}.png")
                results["maps"][key] = dict(tick=frame.state["tick"], bodies=frame.state["bodies"],
                    seconds=round(time.perf_counter() - start, 3))
                reference = ROOT / "validation/reference" / (key + ".png")
                if reference.exists():
                    actual = np.frombuffer(frame.pixels, "uint8").reshape(frame.height, frame.width, 4)[..., :3]
                    expected = np.asarray(Image.open(reference).convert("RGB"))
                    error = np.abs(actual.astype("int16") - expected.astype("int16"))
                    results["maps"][key]["rgb_max_error"] = int(error.max())
                    if args.original_renderer:
                        assert not error.any(), "Original renderer differs from Godot for " + key
                print("MAP", key, results["maps"][key], flush=True)
        sim.action(dict(type="load", map="empty"))
        sim.action(dict(type="pause", value=True))
        sim.action(dict(type="paint", tool=0, material=6, x0=600, y0=300, x1=630, y1=300, radius=5))
        frame = sim.frame()
        def cells():
            identifier = sim.evaluate("app.sim.cells.read.id")
            return sim.host.read_texture(identifier)
        packed = np.frombuffer(cells(), "<u4").reshape(-1, 4)
        assert (packed[:, 0] & 255 == 6).any()
        results["paused_paint"] = True
        sim.action(dict(type="paint", tool=3, material=6, x0=600, y0=300, x1=630, y1=300, radius=7))
        sim.frame()
        packed = np.frombuffer(cells(), "<u4").reshape(-1, 4)
        assert packed[packed[:, 0] & 255 == 6, 1].view("<f4").max() > 300
        results["heat"] = True
        sim.action(dict(type="step"))
        frame = sim.frame()
        assert frame.state["tick"] == 1
        results["single_step"] = True
        saved = cells()
        sim.action(dict(type="save"))
        sim.action(dict(type="clear"))
        sim.frame()
        assert not (np.frombuffer(cells(), "<u4").reshape(-1, 4)[:, 0] & 255 == 6).any()
        results["clear"] = True
        sim.action(dict(type="restore"))
        sim.frame()
        assert saved == cells()
        results["save_restore_exact_cells"] = True
        sim.action(dict(type="resize", width=1024, height=768))
        frame = sim.frame()
        assert frame.width == 1152
        results["resize"] = True
        for mode in range(11):
            sim.action(dict(type="debug", value=mode))
            frame = sim.frame()
            assert frame.width == (1152 if mode == 0 else 512)
        results["debug_views"] = 11
        sim.action(dict(type="debug", value=0))
        sim.action(dict(type="resize", width=1280, height=720))
        sim.action(dict(type="probe", x=500, y=300, request_id=27))
        frame = sim.frame()
        assert frame.state["probe"]["request_id"] == 27
        results["gpu_probe"] = True
        demos = json.loads((ROOT / "Assets/Workshop/ui/demos.json").read_text("utf-8"))
        results["demos"] = []
        for demo in demos:
            sim.action(dict(type="demo", key=demo["key"]))
            frame = sim.frame()
            assert frame.state["demo"] == demo["key"]
            sim.action(dict(type="demo_stop"))
            results["demos"].append(demo["key"])
        results["shaders_compiled"] = len(sim.host.shaders)
        for path in sim.host.metadata:
            sim.host.load_shader(path)
        results["all_shaders_compiled"] = len(sim.host.shaders)
        from native.world_state_capture import WorldStateCapture
        sim.call("setWorldObservationEnabled", True)
        sim.frame()
        snapshot = WorldStateCapture().capture(sim)
        metadata = json.loads(snapshot.metadata_json)
        assert len(metadata["fields"]) == 15
        assert "gpu_resources" not in metadata and metadata["boundary"]["tick"] == metadata["trace"]["tick_end"]
        source = snapshot.copy_field_bytes("cells_packed")
        packed = np.frombuffer(source, "<u4").reshape(288, 512, 4)
        assert np.array_equal(np.frombuffer(snapshot.fields["material_id"], "uint8").reshape(288, 512), packed[..., 0] & 255)
        assert snapshot.fields["temperature_kelvin"] == packed[..., 1].copy().tobytes()
        results["world_snapshot_fields"] = len(snapshot.fields)
        from types import SimpleNamespace
        from ui.material_tile import material_tile
        dropped = []
        app = SimpleNamespace(hotbar=["sand", "water"], material_id=14, dragging=False,
            drag_source=dict(material=6, slot=-1, origin=(0, 0)),
            assign_hotbar=lambda slot, identifier: dropped.append((slot, identifier)))
        canvas = SimpleNamespace(interactive=True, mouse=(30, 30),
            button=lambda *a, **kw: None, icon=lambda *a: None, text=lambda *a, **kw: None,
            hit=lambda rect: True, ctx=SimpleNamespace(is_mouse_button_down=lambda b: False,
                                                      is_mouse_button_clicked=lambda b: False))
        material_tile(canvas, app, (0, 0, 62, 84), dict(id=14, key="sand", zh="沙子"), 0)
        assert dropped == [(0, 6)]
        results["fast_drag_release"] = True
    finally:
        sim.close()
    (output_directory / (results['renderer'] + '-port-report.json')).write_text(json.dumps(results, indent=2, ensure_ascii=False), "utf-8")
    print("PORT_VERIFICATION_PASS", json.dumps(results, ensure_ascii=False), flush=True)


if __name__ == "__main__":
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--maps", action="store_true")
    parser.add_argument("--compare", action="store_true")
    parser.add_argument("--original-renderer", action="store_true",
                        help="Disable the intentional glow/fog correction for the archived Godot pixel comparison")
    verify(parser.parse_args())
