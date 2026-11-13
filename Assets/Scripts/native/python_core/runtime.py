"""Python-owned world state, action dispatch, demo playback and frame boundaries."""

import json
import math
from dataclasses import dataclass
from pathlib import Path

import numpy as np
from _infernux_packages.workshop.runtime.library.dependencies import SimpleNamespace, re, struct, time

from ..gpu_host import GpuHost
from .commands import BrushCommands, SimulationStatistics
from .gpu import NativeGPU
from .grid import SimulationGrid
from .observation import WorldObservation
from .renderer import WorldRenderer
from .rigid import RigidBodyWorld
from .rigid_gpu import RigidBodyGpuBridge
from .settings import RenderSettings, WorldCamera, clamp, vector_length


@dataclass(frozen=True)
class Frame:
    pixels: bytes
    width: int
    height: int
    state: dict


class Simulation:
    def __init__(self, assets, save_directory, map_key='titlelab', paused=False, *, lighting_corrections=True):
        self.assets = Path(assets)
        self.host = GpuHost(assets, save_directory, lighting_corrections=lighting_corrections)
        self.closed = False
        try:
            definitions = self.assets.parent/'Scripts/native/python_core'
            self.info = json.loads((self.assets/'original/data/game.json').read_text('utf-8'))
            self.host.metadata = json.loads((definitions/'shaders.json').read_text('utf-8'))
            if lighting_corrections:
                self.registerLightingOcclusion()
            day_cycle = json.loads((definitions/'day_cycle.json').read_text('utf-8'))
            defaults = json.loads((definitions/'simulation_settings.json').read_text('utf-8'))
            self.demos = json.loads((definitions/'demos.json').read_text('utf-8'))
            self.titleSteps = json.loads((definitions/'title_steps.json').read_text('utf-8'))
            self.gpu = NativeGPU(self.host)
            self.app = SimpleNamespace(W=512, H=288, materials=self.info['materials'],
                settings=RenderSettings(self.info['renderSettings'], day_cycle), camera=WorldCamera(),
                commands=BrushCommands(), currentMap='lab', currentBackground=None,
                paused=False, speed=1, time=0, accum=0, steps=0, bodify=False,
                stats=SimulationStatistics(), probe=dict(valid=False), probePoint=None, selected=14)
            app = self.app
            data = dict(info=self.info, materials=self.host.read_file('materials.bin'),
                        reactions=self.host.read_file('reactions.bin'), lut=self.host.read_file('lut.bin'))
            app.sim = SimulationGrid(self.gpu, 512, 288, data, defaults)
            app.render = WorldRenderer(self.gpu, 512, 288, app.settings, (definitions/'grading_lut.bin').read_bytes())
            app.rigid = RigidBodyWorld(512, 288, app.materials)
            app.bodyGpu = RigidBodyGpuBridge(self.gpu, 512, 288)
            app.camera.worldSize, app.camera.screen = [512, 288], [1536, 864]
            app.camera.fit()
            self.sceneRevision = self.titleElapsed = 0
            self.demo = SimpleNamespace(current=None, t=0, next=0, caption='', alpha=0, saved=[], freeze=False)
            self.observation = WorldObservation()
            self.loadMap(map_key)
            self.action(dict(type='pause', value=paused))
        except BaseException:
            self.host.close()
            raise

    def registerLightingOcclusion(self):
        for name in WorldRenderer.OCCLUSION_PASSES:
            bindings = self.host.metadata['render/'+name+'.comp']['bindings']
            for binding, label in ((30, 'occlusion_extinction'), (31, 'occlusion_emission')):
                bindings.append(dict(group=0, binding=binding, name=label, kind='texture', dim='2d', sampleType='float'))
            if name not in ('front_fog', 'view3d'):
                bindings.append(dict(group=0, binding=32, name='occlusion_view', kind='uniform'))

    def stopDemo(self):
        if self.demo.current:
            self.app.settings.freezeTime = self.demo.freeze
            for key, value in self.demo.saved:
                self.app.settings.set(key, value)
        self.demo.current, self.demo.caption, self.demo.alpha, self.demo.saved = None, '', 0, []

    def playDemo(self, key):
        item = next((item for item in self.demos if item['key'] == key), None)
        if item is None:
            raise ValueError('Unknown demo: '+key)
        self.stopDemo()
        self.loadMap(item['scene'])
        settings = self.app.settings
        self.demo.freeze = settings.freezeTime
        # 退出演示时恢复临时设置，避免编排参数污染后续实验
        self.demo.saved = [(key, settings.v[key]) for key, _ in item['settings']]
        for key, value in item['settings']:
            settings.set(key, value)
        settings.freezeTime, settings.timeOfDay = True, item['timeOfDay']
        self.app.paused = False
        item['steps'].sort(key=lambda entry: entry[0])
        self.demo.t = self.demo.next = 0
        self.demo.current = item

    def replay(self, actions):
        for action in actions:
            if action['type'] == 'command':
                self.app.commands.add(action['value'])
            elif action['type'] == 'bodify':
                self.app.bodify = True
            elif action['key'] == 'timeOfDay':
                self.app.settings.timeOfDay = action['value']
            else:
                self.app.settings.set(action['key'], action['value'])

    def updateDemo(self, delta):
        item = self.demo.current
        if item is None:
            return
        self.demo.t += delta
        time = self.demo.t
        # 补齐本帧跨过的事件，避免低帧率时漏掉时间线动作
        while self.demo.next < len(item['steps']) and item['steps'][self.demo.next][0] <= time:
            self.replay(item['steps'][self.demo.next][1])
            self.demo.next += 1
        if item['cam']:
            index = 0
            while index+1 < len(item['cam']) and item['cam'][index+1][0] <= time:
                index += 1
            first, second = item['cam'][index], item['cam'][min(index+1, len(item['cam'])-1)]
            duration = min(1.6, max(second[0]-first[0], .01))
            fraction = clamp((time-(second[0]-duration))/duration, 0, 1) if second[0] > first[0] else 0
            fraction = fraction*fraction*(3-2*fraction)
            self.app.camera.setView([first[axis]+(second[axis]-first[axis])*fraction for axis in (1, 2)],
                                   first[3]+(second[3]-first[3])*fraction)
        self.demo.caption, self.demo.alpha = '', 0
        for start, duration, caption, *_ in item['captions']:
            if time >= start and time < start+duration:
                self.demo.caption = caption
                self.demo.alpha = clamp(min(time-start, start+duration-time)/.4, 0, 1)
        if time >= item['length']:
            self.stopDemo()

    def loadMap(self, key):
        app, gpu = self.app, self.gpu
        self.sceneRevision += 1
        self.titleElapsed = 0
        app.probe, app.probePoint = dict(valid=False), None
        cells = self.host.read_file('maps/'+key+'.cells.gz')
        background = self.host.read_file('maps/'+key+'.bg.gz')
        app.currentMap, app.currentBackground = key, background
        app.sim.upload(cells)
        app.render.uploadBackground(background)
        app.rigid.clear()
        app.rigid.onCells(cells)
        app.bodify = False
        app.time = app.accum = 0
        app.camera.fit()
        # 切图后重置光照历史，避免新地图混入上一场景的余光
        for pair in (app.render.fluence, app.render.day, app.render.beamTex, app.render.beamDir,
                     app.render.sub, app.render.chA, app.render.chB):
            gpu.clearTexture(pair.read)
            gpu.clearTexture(pair.write)
        for texture in (app.render.ldir, *app.render.cascades, app.render.upperAvg):
            gpu.clearTexture(texture)
        gpu.writeBuffer(app.render.exposureBuf, 0, np.asarray([0, 0, 0, 1], '<f4'))
        app.render.frame = app.render.lastTime = 0
        app.settings.timeOfDay = 9.5 if key == 'titlelab' else 10
        self.observation.recordReset('load', key)

    def updateTitle(self, delta):
        if self.app.currentMap != 'titlelab':
            return
        self.app.camera.center = [self.app.W/2, self.app.H/2]
        # 主页编排依赖双次计时，合并会改变原版动作触发时刻
        self.titleElapsed += delta
        previous = self.titleElapsed
        self.titleElapsed += delta
        for time, actions in self.titleSteps:
            if time > previous and time <= self.titleElapsed:
                self.replay(actions)
        if self.titleElapsed >= 22:
            self.loadMap('titlelab')

    def action(self, action):
        app = self.app
        epoch, tick = self.observation.worldEpoch, app.sim.tick
        kind, handled = action['type'], True
        if kind == 'load':
            self.stopDemo()
            self.loadMap(action['map'])
        elif kind == 'demo':
            self.playDemo(action['key'])
        elif kind == 'demo_stop':
            self.stopDemo()
        elif kind == 'pause':
            app.paused = bool(action['value'])
        elif kind == 'step':
            app.steps += 1
        elif kind == 'speed':
            app.speed = action['value']
        elif kind == 'time':
            app.settings.timeOfDay = action['value']
        elif kind == 'setting':
            app.settings.set(action['key'], action['value'])
        elif kind == 'debug':
            app.render.mode = action['value']
        elif kind == 'resize':
            app.camera.screen = [action['width'], action['height']]
            app.camera.fit()
            # 视图尺寸对齐8像素，满足渲染工作组的整块布局
            height = int(clamp(app.settings.n('ViewHeight'), 270, 2160)) & -8
            width = math.floor(height*action['width']/action['height']+.5) & -8
            app.render.setViewSize(max(64, width), height)
        elif kind == 'fit':
            app.camera.fit()
        elif kind == 'pan':
            app.camera.panBy(action['x'], action['y'])
        elif kind == 'zoom':
            app.camera.zoomBy(action['x'], action['y'], action['factor'])
        elif kind == 'yaw':
            app.camera.turn(action['value'])
        elif kind == 'probe':
            app.probePoint = dict(screen_x=action['x'], screen_y=action['y'], request_id=action.get('request_id', 0))
        elif kind == 'paint':
            self.queuePaintCommand(action)
        elif kind == 'clear':
            app.commands.add(dict(type=7, **{'from':[0, 0], 'to':[0, 0]}, radius=0))
            app.rigid.clear()
            self.observation.recordReset('clear_queued', app.currentMap)
        elif kind == 'save':
            self.host.save_state(app.currentMap, app.settings.timeOfDay,
                self.host.read_texture(app.sim.cells.read.id), app.currentBackground)
        elif kind == 'restore':
            saved = json.loads(self.host.load_saved_info())
            cells = self.host.saved['cells.bin']
            app.sim.upload(cells)
            app.currentBackground = self.host.saved['background.bin']
            app.render.uploadBackground(app.currentBackground)
            self.stopDemo()
            self.sceneRevision += 1
            app.currentMap, app.settings.timeOfDay = saved['map'], saved['time']
            # 存档保存格子材料，刚体需由恢复后的格子重新建立
            app.rigid.clear()
            app.rigid.onCells(cells)
            self.observation.recordReset('restore', app.currentMap)
        else:
            handled = False
        self.observation.recordAction(action, epoch, tick, handled)

    def queuePaintCommand(self, action):
        app, tool = self.app, action['tool']
        kind = {2:2, 3:3, 4:4, 5:5, 6:6}.get(tool, 1)
        command = dict(type=kind, material=app.sim.fireId if tool == 5 else action['material'],
            radius=action['radius']*1.5+4 if tool == 6 else action['radius'], shape=action.get('shape', 0),
            overwrite=bool(action.get('overwrite', False)), spray=.06 if tool == 1 else .5 if tool == 5 else 1,
            strength=40 if tool in (3, 4) else 1.2 if tool == 6 else 0)
        command['from'] = app.camera.screenToCell(action['x0'], action['y0'])
        command['to'] = app.camera.screenToCell(action['x1'], action['y1'])
        app.commands.add(command)
        if tool <= 1 and app.materials[action['material']]['flags'] & 256:
            app.bodify = True

    def frame(self, delta=1/60, forced_ticks=-1):
        started = time.perf_counter()
        app = self.app
        self.observation.beginFrame(app, delta, forced_ticks)
        app.time += delta
        self.updateTitle(delta)
        self.updateDemo(delta)
        ticks = 0
        if not app.paused:
            # 累积小数步数，让模拟速率独立于显示帧率
            app.accum += delta*60*app.speed
            ticks = math.floor(app.accum)
            app.accum -= ticks
            if ticks > 2:
                # 限制补算步数，避免卡顿后集中追帧进一步阻塞模拟
                ticks, app.accum = 2, 0
        ticks += app.steps
        app.steps = 0
        if forced_ticks >= 0:
            ticks = forced_ticks
        self.updateCameraAndDaylight(delta)
        self.simulateAndRender(ticks)
        self.updatePointerProbe()
        # 帧尾统一交付归属数据，避免下一帧混用不同边界的读回
        while self.gpu.jobs:
            self.gpu.jobs.pop(0)()
        self.observation.endFrame(app)
        state = self.serializeFrameState()
        pixels = self.host.read_texture(state['texture'])
        state['frame_ms'] = (time.perf_counter()-started)*1000
        state['dispatches'] = self.host.dispatches
        return Frame(pixels, state['width'], state['height'], state)

    def updateCameraAndDaylight(self, delta):
        app, settings, camera = self.app, self.app.settings, self.app.camera
        camera.tiltTopDeg = settings.effectiveTilt
        camera.tiltBottomDeg = settings.n('TiltBottom') if settings.voxel else 0
        camera.tiltCurve, camera.yawMaxDeg = settings.n('TiltCurve'), settings.effectiveYaw
        camera.applyYaw, camera.fovYDeg = settings.voxel, settings.n('FovY')
        camera.update(delta)
        if settings.b('DayCycleOn') and not settings.freezeTime and not app.paused:
            settings.timeOfDay = (settings.timeOfDay+delta*24/max(settings.n('DayLength')*60, 1)*app.speed) % 24
        settings.frameParallax = [-(camera.center[0]-256)/256*settings.n('Parallax')+math.tan(camera.userYaw*math.pi/180)*.5,
                                 -(camera.center[1]-144)/144*settings.n('Parallax')]

    def simulateAndRender(self, ticks):
        app, gpu = self.app, self.gpu
        packet = app.rigid.update(ticks/60, ticks == 0)
        gpu.begin()
        app.bodyGpu.preStep(app.sim, packet)
        for ordinal in range(ticks):
            # 追赶多步时只消费一次笔刷，避免同一输入被重复施加
            commands = app.commands if ordinal == 0 else None
            boundary = self.observation.beginGridBoundary(app, commands, 'grid_step', ordinal)
            app.sim.step(commands)
            self.observation.endGridBoundary(boundary, app)
        if ticks == 0 and app.commands.count:
            # 暂停时仍应用编辑命令，保证画笔操作即时反馈
            boundary = self.observation.beginGridBoundary(app, app.commands, 'paused_commands', 0)
            app.sim.applyCommandsOnly(app.commands)
            self.observation.endGridBoundary(boundary, app)
        app.bodyGpu.postStep(app.sim, packet.frame, app.rigid.onOccupancy, app.rigid.onOwners)
        app.sim.lightTex, app.sim.daylightTex = app.render.fluenceTex, app.render.daylightTex
        app.render.render(app.sim, app.time, app.camera.view)
        output = app.render.output if app.render.mode == 0 else app.render.debugOutput
        # 同一提交汇总读回，减少统计与画面之间的同步等待
        self.host.queue_frame_readbacks(app.sim.statsBuf.id, SimulationStatistics.SizeBytes,
            app.bodyGpu.occ.id, app.W*app.H//4, app.bodyGpu.owner.id, app.bodyGpu.atlasUsed*4, output.id)
        gpu.submit()
        if app.bodify:
            app.bodify = False
            app.rigid.onCells(self.host.read_texture(app.sim.cells.read.id))
        app.stats.parse(self.host.read_buffer(app.sim.statsBuf.id, 0, SimulationStatistics.SizeBytes))
        self.observation.recordExplosions(app.stats.explosions)
        for explosion in app.stats.explosions:
            app.camera.addShake(clamp(explosion[3]*explosion[2]*.08, .2, 2.5))
            app.rigid.blast(explosion)

    def updatePointerProbe(self):
        app = self.app
        if app.probePoint is None:
            return
        request = app.probePoint
        point = app.camera.screenToCell(request['screen_x'], request['screen_y'])
        app.probe = dict(request, valid=False)
        if all(math.isfinite(value) for value in point):
            x, y = math.floor(point[0]), math.floor(point[1])
            if 0 <= x < app.W and 0 <= y < app.H:
                # 探针仅回读目标格子，避免悬停查询触发整图传输
                data = self.host.read_texture(app.sim.cells.read.id, x, y, 1, 1, 16)
                material, temperature = struct.unpack_from('<If', data)
                temperature -= 273.15
                app.probe = dict(request, valid=math.isfinite(temperature), x=x, y=y, material=material&255, temp=temperature)
        app.probePoint = None

    def serializeFrameState(self):
        app, settings, camera, stats = self.app, self.app.settings, self.app.camera, self.app.stats
        output = app.render.output if app.render.mode == 0 else app.render.debugOutput
        return dict(texture=output.id, width=output.width, height=output.height, tick=app.sim.tick,
            time=app.time, day=settings.timeOfDay, bodies=len(app.rigid.bodies), map=app.currentMap,
            title_elapsed=self.titleElapsed, paused=app.paused, probe=dict(app.probe),
            events=stats.events.tolist(), explosions=stats.explosions, histogram=stats.histogram.tolist(),
            reactions=stats.reactionCount.tolist(), ignite=stats.igniteCount.tolist(),
            phase_hi=stats.phaseHi.tolist(), phase_lo=stats.phaseLo.tolist(), scene_revision=self.sceneRevision,
            frame=app.render.frame, demo=self.demo.current['key'] if self.demo.current else '',
            demo_caption=self.demo.caption, demo_alpha=self.demo.alpha, vignette=settings.n('Vignette'),
            grain=settings.n('Grain'), chroma=settings.n('Chroma')*min(vector_length(*camera.shake)*.4+.15, 1),
            zoom=camera.zoom, camera_center=list(camera.view.center), camera_size=list(camera.screen), view_mode=app.render.mode)

    def call(self, name, *args):
        methods = {'loadMap':self.loadMap, 'setWorldObservationEnabled':self.observation.setEnabled,
                   'describeWorldObservation':lambda: json.dumps(self.observation.describe(self), ensure_ascii=False)}
        return methods[name](*args)

    def read_cpu_field(self, name):
        if name != 'background_rgba':
            raise KeyError(name)
        return bytes(self.app.currentBackground)

    def set_camera_view(self, center, zoom):
        self.app.camera.setView(center, zoom)

    def evaluate(self, path):
        """Compatibility for validation tools reading resource paths; no code execution."""
        # 路径校验维持旧工具的查询接口，避免将输入作为代码执行
        if not re.fullmatch(r'app(?:\.[A-Za-z_][A-Za-z_0-9]*|\[\d+\])*', path):
            raise ValueError('Use the Python app objects for operations; only resource paths can be inspected')
        value = self.app
        for attribute, index in re.findall(r'\.([A-Za-z_][A-Za-z_0-9]*)|\[(\d+)\]', path[3:]):
            value = getattr(value, attribute) if attribute else value[int(index)]
        return value

    def close(self):
        if not self.closed:
            self.host.close()
            self.closed = True
