"""GPU regression: blocked local glow, glass transmission, camera and original lighting."""
import json
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
sys.path[:0] = [str(ROOT / '.runtime/packages'), str(ROOT / 'Assets/Scripts')]
from workshop_bootstrap import preload_dependencies
preload_dependencies(ROOT)
import numpy as np
from PIL import Image, ImageDraw
from native.game_runtime import Simulation

OUT = ROOT / 'validation/lighting'
OUT.mkdir(exist_ok=True)


def texture(sim, expression, dtype='<f2'):
    identifier = sim.evaluate(expression + '.id')
    width, height, _, _ = sim.host.dimensions[identifier]
    return np.frombuffer(sim.host.read_texture(identifier), dtype).reshape(height, width, -1).astype('float32')


def prepare(sim, case):
    sim.action(dict(type='load', map='lab' if case == 'sodium' else 'empty'))
    for key, value in dict(DayCycleOn=False, Daylight=0, SkyIntensity=0, SunIntensity=0,
                           AmbientIntensity=0, AutoExposure=False, Grain=0, HeatDistortion=0,
                           Enable3D=True, VoxelExtrude=False, TheatreHaze=.0035).items():
        sim.action(dict(type='setting', key=key, value=value))
    cells = np.zeros((288, 512, 4), '<u4')
    cells[..., 1] = np.float32(293).view('<u4')
    cells[104:120, 248:264, 0] = 33
    cells[140:146, 190:322, 0] = 31
    if case == 'free':
        cells[140:146, 190:322, 0] = 0
        sim.action(dict(type='setting', key='TheatreHaze', value=0))
    elif case == 'thin':
        cells[122:123, :, 0] = 21
    elif case == 'stone':
        cells[122:124, :, 0] = 21
    elif case == 'iron':
        cells[122:124, :, 0] = 31
    elif case == 'glass':
        cells[122:124, :, 0] = 23
    elif case == 'gap':
        cells[122:124, :, 0] = 21
        cells[122:124, 246:266, 0] = 0
    elif case == 'diagonal':
        for x in range(512):
            y = 122 + (x - 256) // 4
            if 0 <= y < 285:
                cells[y:y+2, x, 0] = 21
    elif case == 'sodium':
        cells = np.frombuffer(sim.host.read_file('maps/lab.cells.gz'), '<u4').reshape(288,512,4).copy()
        cells[147:160,444:450,1] = np.float32(2270).view('<u4')
        cells[170:176,335:494,0] = 31
        # Keep the original daylight and atmosphere for the screenshot reproduction.
        for key, value in dict(Daylight=1.6, SkyIntensity=1.4, SunIntensity=60, AmbientIntensity=.09).items():
            sim.action(dict(type='setting', key=key, value=value))
    for side in ('read', 'write'):
        sim.host.upload_texture(sim.evaluate('app.sim.cells.' + side + '.id'), cells.tobytes())
    if case != 'sodium':
        background = np.zeros((288,512,4), 'uint8')
        background[..., 0] = 1
        sim.host.upload_texture(sim.evaluate('app.render.background.id'), background.tobytes())
    return cells


def capture(sim, label):
    for _ in range(48):
        frame = sim.frame(1/60)
    images = {key: texture(sim, expression) for key, expression in {
        'fluence':'app.render.fluence.read', 'surface':'app.render.l0s',
        'hdr':'app.render.main.hdr', 'bloom':'app.render.main.bloomUp[1]',
        'fog':'app.render.fogTex', 'emission':'app.render.emissive',
    }.items()}
    images['final'] = np.frombuffer(frame.pixels, 'uint8').reshape(frame.height,frame.width,4).copy()
    Image.fromarray(images['final']).save(OUT / (label + '.png'))
    if label in ('sodium-before', 'sodium-after'):
        np.savez_compressed(OUT / (label + '.npz'), **images)
    return images


def mean_world(image, bounds):
    x0,y0,x1,y1 = bounds
    h,w = image.shape[:2]
    return float(image[round(y0*h/288):round(y1*h/288), round(x0*w/512):round(x1*w/512),:3].mean())


def verify():
    results = {}
    captures = {}
    cases = ('free','open','thin','stone','iron','glass','gap','diagonal','sodium')
    for corrected in (False, True):
        variant = 'after' if corrected else 'before'
        sim = Simulation(ROOT / 'Assets/Workshop', OUT / 'test-saves', 'empty', True,
                         lighting_corrections=corrected)
        try:
            for case in cases:
                prepare(sim,case)
                label = case + '-' + variant
                images = capture(sim,label)
                captures[label] = images
                bounds = (442,170,451,174) if case == 'sodium' else (248,140,264,144)
                results[label] = {key:mean_world(value,bounds) for key,value in images.items()}
                print(label, results[label], flush=True)
            # Check camera mapping at a translated, magnified view.
            prepare(sim,'iron')
            sim.set_camera_view([256, 130], 2.0)
            captures['zoom-'+variant] = capture(sim,'zoom-'+variant)
            for mode in ('flat','voxel'):
                prepare(sim,'iron')
                sim.action(dict(type='setting', key='Enable3D' if mode == 'flat' else 'VoxelExtrude', value=mode=='voxel'))
                captures[mode+'-'+variant] = capture(sim,mode+'-'+variant)
            if corrected:
                # Inserting a wall and then removing it must use the live gbuffer.
                cells = prepare(sim,'open')
                capture(sim,'moving-open')
                cells[122:124,:,0] = 31
                for side in ('read','write'):
                    sim.host.upload_texture(sim.evaluate('app.sim.cells.'+side+'.id'), cells.tobytes())
                blocked = capture(sim,'moving-blocked')
                cells[122:124,:,0] = 0
                for side in ('read','write'):
                    sim.host.upload_texture(sim.evaluate('app.sim.cells.'+side+'.id'), cells.tobytes())
                opened = capture(sim,'moving-reopened')
                assert mean_world(blocked['bloom'],(248,140,264,144)) < mean_world(opened['bloom'],(248,140,264,144))*.01
        finally:
            sim.close()
    for case in cases:
        before, after = (captures[case+'-'+variant] for variant in ('before','after'))
        # A display correction must not change simulation irradiance or material shading.
        for field in ('fluence', 'surface', 'emission'):
            assert np.array_equal(before[field], after[field]), (case, field)
    assertions = {}
    for case in ('thin', 'stone', 'iron', 'diagonal', 'sodium'):
        before, after = results[case+'-before'], results[case+'-after']
        assertions[case] = dict(fog_ratio=after['fog']/max(before['fog'],1e-12),
                                bloom_ratio=after['bloom']/max(before['bloom'],1e-12))
        assert assertions[case]['fog_ratio'] < .01, (case, assertions[case])
        assert assertions[case]['bloom_ratio'] < .01, (case, assertions[case])
    free_ratio = float(captures['free-after']['bloom'][...,:3].sum()/captures['free-before']['bloom'][...,:3].sum())
    assert .98 < free_ratio < 1.02, free_ratio
    assert results['glass-after']['bloom'] > results['iron-after']['bloom']*100
    assert results['gap-after']['bloom'] > results['iron-after']['bloom']*100
    for mode, bounds in [('zoom',(240,164,272,172)), ('flat',(248,140,264,144)), ('voxel',(248,140,264,144))]:
        ratio = mean_world(captures[mode+'-after']['bloom'],bounds)/max(mean_world(captures[mode+'-before']['bloom'],bounds),1e-9)
        assertions[mode] = dict(bloom_ratio=ratio)
        assert ratio < .02, (mode, ratio)
    # Avoid hiding the original unmodified pixel references with new golden images.
    report = dict(passed=True, cases=results, occlusion=assertions,
                  original_light_fields_unchanged=True,
                  free_space_bloom_energy_ratio=free_ratio, moving_blocker_passed=True,
                  source='real GPU, fixed scenes and camera, 48 warm frames each')
    (OUT/'report.json').write_text(json.dumps(report,indent=2), 'utf-8')
    print('OCCLUSION', assertions, flush=True)
    for case in ('sodium','iron','glass'):
        canvas = Image.new('RGB',(1092,282), '#161a24')
        draw = ImageDraw.Draw(canvas)
        for index, variant in enumerate(('before','after')):
            image = Image.fromarray(captures[case+'-'+variant]['final']).convert('RGB')
            bounds = (990,330,1536,580) if case == 'sodium' else (495,240,1041,490)
            canvas.paste(image.crop(bounds),(index*546,32))
            draw.text((index*546+12,10),variant,fill='white')
        canvas.save(OUT/(case+'-comparison.png'))
    print('LIGHTING_OCCLUSION_PASS', flush=True)


if __name__ == '__main__':
    verify()
