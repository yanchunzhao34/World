"""Compare optimized boundaries with the original runtime and direct GPU reads."""

import json
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
sys.path.insert(0, str(ROOT / "Assets/Scripts"))

from workshop_bootstrap import preload_dependencies

DEPENDENCIES = preload_dependencies(ROOT)

from native.game_runtime import Simulation, decode_binary, encode_binary
from native.python_core.reference import ReferenceSimulation
from native.python_core.rigid import RigidBodyWorld
import numpy as np


def verify():
    sim = ReferenceSimulation(ROOT / "Assets/Workshop", ROOT / "validation/optimization-saves", "lab", True)
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


def verify_python_core():
    """Compare real dispatches, binary fields, UI state and complete demo timelines."""
    reference = ReferenceSimulation(ROOT/'Assets/Workshop', ROOT/'validation/python-core-reference', 'lab', True)
    actual = Simulation(ROOT/'Assets/Workshop', ROOT/'validation/python-core-test', 'lab', True)
    traces = [[], []]
    report = dict(maps={}, action_frames=0, demo_timelines=0)
    try:
        for index, simulation in enumerate((reference, actual)):
            original = simulation.host.dispatch

            def dispatch(path, bindings, parameters, x, y, z, original=original, index=index):
                traces[index].append((path, bytes(parameters), x, y, z))
                return original(path, bindings, parameters, x, y, z)

            simulation.host.dispatch = dispatch

        def compare_frame(delta=1/60, forced_ticks=-1):
            for trace in traces:
                trace.clear()
            before, after = reference.frame(delta, forced_ticks), actual.frame(delta, forced_ticks)
            assert traces[0] == traces[1], 'GPU dispatch parameters or ordering differ'
            assert before.pixels == after.pixels, 'Frame pixels differ'
            skip = {'texture', 'frame_ms', 'dispatches'}
            expected = {key:value for key,value in before.state.items() if key not in skip}
            observed = {key:value for key,value in after.state.items() if key not in skip}
            assert expected == observed, [key for key in expected if expected[key] != observed[key]]
            for expression in ('app.sim.cells.read.id', 'app.sim.fluidVel.read.id', 'app.sim.medium.read.id'):
                old = reference.host.read_texture(reference.evaluate(expression))
                new = actual.host.read_texture(actual.evaluate(expression))
                assert old == new, expression

        for map_key in ('lab','cave','volcano','gallery','optics','energy','cover','empty','titlelab'):
            for simulation in (reference, actual):
                simulation.action(dict(type='load', map=map_key))
                simulation.action(dict(type='pause', value=False))
            for _ in range(16):
                compare_frame()
            report['maps'][map_key] = 16
            print('PYTHON_CORE_MAP_PARITY', map_key, flush=True)

        for simulation in (reference, actual):
            simulation.action(dict(type='load', map='empty'))
            simulation.action(dict(type='pause', value=True))
        actions = [dict(type='paint', tool=0, material=6, x0=600,y0=300,x1=630,y1=300,radius=5),
            dict(type='paint',tool=3,material=6,x0=600,y0=300,x1=630,y1=300,radius=7),
            dict(type='step'), dict(type='save'), dict(type='clear'), dict(type='restore'),
            dict(type='resize',width=1024,height=768),dict(type='pan',x=27,y=-19),
            dict(type='zoom',x=490,y=320,factor=1.2),dict(type='yaw',value=9),
            dict(type='probe',x=500,y=300,request_id=27)]
        actions.extend(dict(type='debug',value=mode) for mode in range(11))
        actions.extend([dict(type='debug',value=0),dict(type='setting',key='VoxelExtrude',value=True),
                        dict(type='setting',key='DofStrength',value=.4),dict(type='setting',key='Enable3D',value=False)])
        for action in actions:
            reference.action(action)
            actual.action(action)
            compare_frame()
            report['action_frames'] += 1
        # Exchange actual ZIP saves through each implementation's normal restore action.
        for source, destination in ((reference, actual), (actual, reference)):
            source.action(dict(type='save'))
            save_bytes = (source.host.save_directory/'quick.ewsave').read_bytes()
            (destination.host.save_directory/'quick.ewsave').write_bytes(save_bytes)
            destination.action(dict(type='clear'))
            destination.frame()
            destination.action(dict(type='restore'))
            for simulation in (source, destination):
                simulation.host.load_saved_info()
            assert source.host.saved == destination.host.saved, 'Exchanged ZIP entries differ'
            assert source.host.saved['cells.bin'] == destination.host.read_texture(destination.evaluate('app.sim.cells.read.id'))
            assert source.read_cpu_field('background_rgba') == destination.read_cpu_field('background_rgba')
        report['save_layout'] = 'JS-to-Python and Python-to-JS ZIP restore matches all entries'

        reference.action(dict(type='setting',key='Enable3D',value=True))
        actual.action(dict(type='setting',key='Enable3D',value=True))
        probe_expression = '''JSON.stringify({commands:app.commands.pending,bodify:app.bodify,
            settings:app.settings.v,day:app.settings.timeOfDay,freeze:app.settings.freezeTime,
            center:app.camera.center,zoom:app.camera.zoom,current:demo.current?demo.current.key:'',
            caption:demo.caption,alpha:demo.alpha,next:demo.next,time:demo.t})'''
        for item in actual.demos:
            reference.call('playDemo',item['key'])
            actual.playDemo(item['key'])
            for _ in range(int(item['length']/.37)+2):
                reference.call('updateDemo',.37)
                actual.updateDemo(.37)
                expected = json.loads(reference.evaluate(probe_expression))
                app, demo = actual.app, actual.demo
                observed = dict(commands=app.commands.pending,bodify=app.bodify,
                    settings=app.settings.v,day=app.settings.timeOfDay,freeze=app.settings.freezeTime,
                    center=app.camera.center,zoom=app.camera.zoom,current=demo.current['key'] if demo.current else '',
                    caption=demo.caption,alpha=demo.alpha,next=demo.next,time=demo.t)
                assert expected == observed, (item['key'], [key for key in expected if expected[key]!=observed[key]])
                reference.evaluate('app.commands.pending.length=0')
                app.commands.pending.clear()
            report['demo_timelines'] += 1
        print('PYTHON_CORE_DEMO_TIMELINES_MATCH', report['demo_timelines'], flush=True)
        report['rigid_frames'] = verify_python_rigid(reference)

        for simulation in (reference, actual):
            simulation.action(dict(type='load',map='lab'))
            simulation.action(dict(type='pause',value=True))
            simulation.call('setWorldObservationEnabled',True)
        compare_frame()
        from native.world_state_capture import WorldStateCapture
        captures = [WorldStateCapture().capture(simulation) for simulation in (reference, actual)]
        metadata = [json.loads(capture.metadata_json) for capture in captures]
        for item in metadata:
            item.pop('runtime_session_id')
        assert metadata[0] == metadata[1], 'World observation metadata differs'
        assert dict(captures[0].fields) == dict(captures[1].fields), 'World observation arrays differ'
        report.update(world_observation_fields=len(captures[0].fields), passed=True)
    finally:
        reference.close()
        actual.close()
    (ROOT/'validation/python-core-parity.json').write_text(json.dumps(report,indent=2),'utf-8')
    print('PYTHON_CORE_PARITY_PASS',json.dumps(report),flush=True)


def verify_python_rigid(reference):
    """Exercise contacts, liquid buoyancy, fracture, sleeping and world edges."""
    materials = json.loads((ROOT/'Assets/Workshop/original/data/game.json').read_text('utf-8'))['materials']
    iron = next(item['id'] for item in materials if item['key'] == 'iron')
    world = RigidBodyWorld(64, 48, materials)
    image = np.full(32, iron, 'uint8')
    image[[0, 7, 24, 31]] = 0
    world.createFromImage(8, 4, image, [20, 9], .2, [5, -20], .1)
    world.createFromImage(8, 4, image, [25, 24], -.15)
    reference.evaluate('var parityRigid=new RigidBodyWorld(64,48,app.materials);')
    for origin, angle, velocity, angular in [([20,9],.2,[5,-20],.1),([25,24],-.15,[0,0],0)]:
        reference.evaluate('parityRigid.createFromImage(8,4,new Uint8Array('+json.dumps(image.tolist())+'),'+
            json.dumps(origin)+','+str(angle)+','+json.dumps(velocity)+','+str(angular)+');')
    occupancy = np.zeros((48,64), 'uint8')
    occupancy[24:44] = 2
    occupancy[44:] = 1
    packed = ((occupancy.reshape(-1,4).astype('<u4') << np.asarray([0,2,4,6],'<u4')).sum(axis=1)).astype('uint8').tobytes()
    reference.js.set('parityOccupancy',encode_binary(packed))
    for frame in range(180):
        if frame == 24:
            world.blast([26,25,10,1.2])
            reference.evaluate('parityRigid.blast([26,25,10,1.2]);')
        if frame == 50:
            owners = np.concatenate((np.ones(32,'<u4'), np.full(32,2,'<u4')))
            owners[[3,11,19,27]] = 0xffffffff
            world.onOwners(owners.tobytes(),frame+3)
            reference.js.set('parityOwners',encode_binary(owners.tobytes()))
            reference.evaluate('parityRigid.onOwners(arrayBuffer(parityOwners),'+str(frame+3)+');')
        if frame == 100:
            world.bodies[0].vel = [600,-200]
            reference.evaluate('parityRigid.bodies[0].vel=[600,-200];')
        world.onOccupancy(packed)
        reference.evaluate('parityRigid.onOccupancy(arrayBuffer(parityOccupancy));')
        packet = world.update(1/60,False)
        expected = json.loads(reference.evaluate('''JSON.stringify((()=>{
            const packet=parityRigid.update(1/60,false);
            return {bytes:Array.from(new Uint8Array(packet.bodies.buffer)),claims:packet.claims,
                    updates:packet.ownerUpdates,count:packet.count};
        })())'''))
        assert packet.bodies == bytes(expected['bytes']), ('rigid bytes',frame)
        assert packet.claims == expected['claims'] and packet.ownerUpdates == expected['updates'], ('rigid ownership',frame)
        assert packet.count == expected['count'],('rigid count',frame)
    # Exercise both out-of-buffer reads and the original valid cross-row indexing.
    for origin in ([-5,0], [68,47], [-3,1], [65,46]):
        boundary = RigidBodyWorld(64,48,materials)
        body = boundary.createFromImage(1,1,[iron],origin)
        boundary.haveOcc = True
        boundary.occ.fill(2)
        boundary.integrate(body,1/60)
        reference.evaluate('''var boundaryRigid=new RigidBodyWorld(64,48,app.materials);
            boundaryRigid.createFromImage(1,1,new Uint8Array(['''+str(iron)+''']),'''+json.dumps(origin)+''');
            boundaryRigid.haveOcc=true; boundaryRigid.occ.fill(2);
            boundaryRigid.integrate(boundaryRigid.bodies[0],1/60);''')
        expected = json.loads(reference.evaluate('''JSON.stringify({
            bytes:Array.from(new Uint8Array(boundaryRigid.snapshot(true).bodies.buffer)),
            wetRows:Array.from(boundaryRigid.wetRows)})'''))
        assert boundary.snapshot(True).bodies == bytes(expected['bytes']), ('boundary body',origin)
        assert sorted(boundary.wetRows) == sorted(expected['wetRows']), ('boundary buoyancy',origin)
    print('PYTHON_CORE_RIGID_PARITY',180,'frames',flush=True)
    return 180


def verify_demo_playback():
    """Play every demo at 60 Hz with deterministic CPU feedback inputs."""
    import struct
    from types import SimpleNamespace
    from native.python_core import settings
    from native.python_core.commands import SimulationStatistics
    from native.python_core.rigid import XorShift32

    reference = ReferenceSimulation(ROOT/'Assets/Workshop', ROOT/'validation/demo-reference', 'lab')
    actual = Simulation(ROOT/'Assets/Workshop', ROOT/'validation/demo-python', 'lab')
    original_random = settings.random
    results = {}
    try:
        # GPU atomic appends can return the same explosions in different orders,
        # including between two JS reference runs. Stabilize their CPU feedback
        # order in this test while preserving every record and all other bytes.
        for simulation in (reference, actual):
            stats_id = simulation.evaluate('app.sim.statsBuf.id')
            original_read = simulation.host.read_buffer

            def read_statistics(identifier, offset, size, stats_id=stats_id, original_read=original_read):
                data = original_read(identifier, offset, size)
                if identifier != stats_id or offset != 0 or size != SimulationStatistics.SizeBytes:
                    return data
                count = min(struct.unpack_from('<I',data,SimulationStatistics.ExCountOffset)[0],
                            SimulationStatistics.MaxExplosions)
                start = SimulationStatistics.ExplosionsOffset
                end = start+count*16
                records = [data[index:index+16] for index in range(start,end,16)]
                records.sort(key=lambda record: struct.unpack('<4f',record))
                return data[:start]+b''.join(records)+data[end:]

            simulation.host.read_buffer = read_statistics
        for item in actual.demos:
            settings.random = SimpleNamespace(random=XorShift32(7).next)
            reference.evaluate('''Math.random=(()=>{let state=7; return ()=>{
                state^=state<<13; state^=state>>>17; state^=state<<5;
                return (state>>>0)/4294967296;
            };})();''')
            for simulation in (reference, actual):
                simulation.action(dict(type='demo',key=item['key']))
            frames = int(item['length']*60)+2
            for ordinal in range(frames):
                expected, observed = reference.frame(), actual.frame()
                context = (item['key'], ordinal)
                assert expected.pixels == observed.pixels, ('demo pixels',context)
                skip = {'texture','frame_ms','dispatches'}
                before = {key:value for key,value in expected.state.items() if key not in skip}
                after = {key:value for key,value in observed.state.items() if key not in skip}
                differences = [(key,before[key],after[key]) for key in before if before[key]!=after[key]]
                assert before == after, ('demo state',context,differences)
                if ordinal % 60 == 0 or ordinal == frames-1:
                    for path in ('app.sim.cells.read.id','app.sim.fluidVel.read.id','app.sim.medium.read.id'):
                        old = reference.host.read_texture(reference.evaluate(path))
                        new = actual.host.read_texture(actual.evaluate(path))
                        assert old == new, ('demo GPU field',context,path)
            assert actual.demo.current is None, ('demo did not finish',item['key'])
            results[item['key']] = frames
            print('PYTHON_CORE_FULL_DEMO_PASS',item['key'],frames,flush=True)
    finally:
        settings.random = original_random
        reference.close()
        actual.close()
    destination = ROOT/'validation/python-core-parity.json'
    report = json.loads(destination.read_text('utf-8'))
    report['demo_playback_frames'] = results
    report['demo_camera_shake'] = 'matching xorshift32 streams for deterministic comparison'
    report['demo_explosion_feedback'] = 'test-only stable ordering of GPU atomic event records; all record bytes retained'
    destination.write_text(json.dumps(report,indent=2),'utf-8')
    print('PYTHON_CORE_FULL_DEMOS_PASS',sum(results.values()),'frames',flush=True)


if __name__ == "__main__":
    verify()
    verify_python_core()
    if '--full-demos' in sys.argv:
        verify_demo_playback()
