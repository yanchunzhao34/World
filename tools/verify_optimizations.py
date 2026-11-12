"""Compare optimized boundaries with the original runtime and direct GPU reads."""

import json
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
sys.path.insert(0, str(ROOT / "Assets/Scripts"))

from workshop_bootstrap import preload_dependencies

DEPENDENCIES = preload_dependencies(ROOT)

from native.game_runtime import Simulation, decode_binary, encode_binary


def verify():
    sim = Simulation(ROOT / "Assets/Workshop", ROOT / "validation/optimization-saves", "lab", True)
    report = {}
    try:
        for length in (0, 1, 2, 3, 255, 256, 257, 65536, 256 * 1024):
            payload = bytes(index % 256 for index in range(length))
            sim.js.set("bridgeTestPayload", encode_binary(payload))
            result = sim.evaluate("byteString(arrayBuffer(bridgeTestPayload))")
            assert decode_binary(result) == payload, length
        payload = bytes(range(256)) * 3
        sim.js.set("bridgeTestPayload", encode_binary(payload))
        for expression, expected in (
            ("new Uint8Array(arrayBuffer(bridgeTestPayload), 13, 517)", payload[13:530]),
            ("new DataView(arrayBuffer(bridgeTestPayload), 7, 511)", payload[7:518]),
            ("new Float32Array(arrayBuffer(bridgeTestPayload), 16, 13)", payload[16:68]),
        ):
            assert decode_binary(sim.evaluate("byteString(" + expression + ")")) == expected
        report["binary_bridge"] = "all byte values, empty/odd/large lengths, typed subviews and DataView"

        result = sim.evaluate(r"""
        (() => {
            const iron = gameInfo.materials.find(material => material.key === 'iron').id;
            for (const [width, height] of [[16, 4], [32, 32], [512, 288]]) {
                const reference = new RigidBodyWorld(width, height, app.materials);
                const actual = new RigidBodyWorld(width, height, app.materials);
                for (const world of [reference, actual]) {
                    world.createFromImage(4, 4, new Uint8Array(16).fill(iron),
                        [4, 1], .2, [5, -20], .1);
                }
                for (let frame = 0; frame < 8; frame++) {
                    const packed = new Uint8Array(width * height / 4);
                    for (let index = 0; index < packed.length; index++)
                        packed[index] = (index + frame * 37) & 255;
                    reference.onOccupancy(packed.slice().buffer);
                    actual.onOccupancy(packed.slice().buffer);
                    const paused = frame % 3 === 0;
                    const expected = workshopOriginalRigidUpdate.call(reference, 1 / 60, paused);
                    const observed = actual.update(1 / 60, paused);
                    const state = (world, packet) => JSON.stringify([
                        packet, world.bodies, world.bodyCells, world.haveOcc,
                        world.occIn, world.frame, byteString(world.occ), byteString(world.bodyAt)
                    ]);
                    if (state(reference, expected) !== state(actual, observed))
                        throw Error('Rigid state differs at ' + width + 'x' + height + ':' + frame);
                }
            }
            return true;
        })()
        """)
        assert result
        report["rigid_equivalence"] = "24 updates match original occupancy, physics state and GPU packets"

        host = sim.host
        resources = []
        try:
            first = host.make_buffer(1024, False)
            second = host.make_buffer(260, False)
            resources.extend([first, second])
            data_a, data_b = bytes(range(256)) * 4, bytes(range(256)) + b"\x00\xff\x01\xfe"
            host.upload_buffer(first, 0, data_a)
            host.upload_buffer(second, 0, data_b)
            retained = []
            for width, height, depth in ((17, 7, 1), (256, 128, 1), (5, 3, 2)):
                texture = host.make_texture(width, height, "rgba8unorm", depth)
                resources.append(texture)
                pixels = bytes(index % 251 for index in range(width * height * depth * 4))
                host.upload_texture(texture, pixels)
                host.queue_frame_readbacks(first, len(data_a), second, len(data_b), first, 0, texture)
                assert host.read_buffer(second, 0, len(data_b)) == data_b
                assert host.read_texture(texture) == pixels
                retained.append((host.read_texture(texture), pixels))
                assert host.read_buffer(first, 0, len(data_a)) == data_a
                host.readback.invalidate()
                assert host.read_texture(texture) == pixels  # direct wgpu read
            for actual, expected in retained:
                assert actual == expected
            host.queue_frame_readbacks(first, len(data_a), second, len(data_b), first, 0, resources[-1])
            assert host.read_buffer(first, 0, len(data_a)) == data_a
            host.clear_buffer(first, 0, len(data_a))
            assert host.read_buffer(first, 0, len(data_a)) == bytes(len(data_a))
            host.upload_buffer(first, 0, data_a)
            assert host.read_buffer(first, 0, len(data_a)) == data_a
            report["gpu_readback"] = "unaligned rows, 3D, buffer growth, direct-read equality, immutable bytes, write invalidation"
        finally:
            for identifier in resources:
                host.destroy(identifier)
        # Return to the normal pipeline after the readback stress cases.
        frame = sim.frame()
        assert frame.state["map"] == "lab" and len(frame.pixels) == frame.width * frame.height * 4
        report["passed"] = True
    finally:
        sim.close()
    (ROOT / "validation/optimizations.json").write_text(
        json.dumps(report, indent=2, ensure_ascii=False), encoding="utf-8")
    print("OPTIMIZATION_EQUIVALENCE_PASS", json.dumps(report), flush=True)


if __name__ == "__main__":
    verify()
