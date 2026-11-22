"""Python-owned world state, action dispatch, demo playback and frame boundaries."""

import json
import math
from dataclasses import dataclass
from pathlib import Path

import numpy as np
from _infernux_packages.workshop.runtime.library.dependencies import (
    SimpleNamespace,
    re,
    struct,
    time,
)

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
    # 初始化游戏世界及各子系统的协作状态。
    def __init__(
        self,
        assets,
        save_directory,
        map_key='titlelab',
        paused=False,
        *,
        lighting_corrections=True,
    ):
        self.assets = Path(assets)
        self.host = GpuHost(
            assets, save_directory, lighting_corrections=lighting_corrections
        )
        self.closed = False

        try:
            definition_directory = self.assets.parent / 'Scripts/native/python_core'
            self.info = json.loads(
                (self.assets / 'original/data/game.json').read_text('utf-8')
            )
            self.host.metadata = json.loads(
                (definition_directory / 'shaders.json').read_text('utf-8')
            )

            if lighting_corrections:
                self.registerLightingOcclusion()

            day_cycle = json.loads(
                (definition_directory / 'day_cycle.json').read_text('utf-8')
            )
            defaults = json.loads(
                (definition_directory / 'simulation_settings.json').read_text('utf-8')
            )
            self.demos = json.loads(
                (definition_directory / 'demos.json').read_text('utf-8')
            )
            self.titleSteps = json.loads(
                (definition_directory / 'title_steps.json').read_text('utf-8')
            )
            self.gpu = NativeGPU(self.host)
            self.app = SimpleNamespace(
                W=512,
                H=288,
                materials=self.info['materials'],
                settings=RenderSettings(self.info['renderSettings'], day_cycle),
                camera=WorldCamera(),
                commands=BrushCommands(),
                currentMap='lab',
                currentBackground=None,
                paused=False,
                speed=1,
                time=0,
                accum=0,
                steps=0,
                bodify=False,
                stats=SimulationStatistics(),
                probe=dict(valid=False),
                probePoint=None,
                selected=14,
            )
            app = self.app
            simulation_data = dict(
                info=self.info,
                materials=self.host.read_file('materials.bin'),
                reactions=self.host.read_file('reactions.bin'),
                lut=self.host.read_file('lut.bin'),
            )
            app.sim = SimulationGrid(self.gpu, 512, 288, simulation_data, defaults)
            app.render = WorldRenderer(
                self.gpu,
                512,
                288,
                app.settings,
                (definition_directory / 'grading_lut.bin').read_bytes(),
            )
            app.rigid = RigidBodyWorld(512, 288, app.materials)
            app.bodyGpu = RigidBodyGpuBridge(self.gpu, 512, 288)
            app.camera.worldSize, app.camera.screen = [512, 288], [1536, 864]

            app.camera.fit()

            self.sceneRevision = 0
            self.titleElapsed = 0
            self.demo = SimpleNamespace(
                current=None,
                t=0,
                next=0,
                caption='',
                alpha=0,
                saved=[],
                freeze=False,
            )
            self.observation = WorldObservation()

            self.loadMap(map_key)
            self.action(dict(type='pause', value=paused))

        except BaseException:
            self.host.close()

            raise

    # 为相关后处理阶段登记材质遮挡绑定。
    def registerLightingOcclusion(self):
        for name in WorldRenderer.OCCLUSION_PASSES:
            bindings = self.host.metadata['render/' + name + '.comp']['bindings']

            for binding, label in (
                (30, 'occlusion_extinction'),
                (31, 'occlusion_emission'),
            ):
                bindings.append(
                    dict(
                        group=0,
                        binding=binding,
                        name=label,
                        kind='texture',
                        dim='2d',
                        sampleType='float',
                    )
                )

            if name not in ('front_fog', 'view3d'):
                bindings.append(
                    dict(
                        group=0,
                        binding=32,
                        name='occlusion_view',
                        kind='uniform',
                    )
                )

    # 结束演示并恢复其临时修改的设置。
    def stopDemo(self):
        if self.demo.current:
            self.app.settings.freezeTime = self.demo.freeze

            for key, value in self.demo.saved:
                self.app.settings.set(key, value)

        self.demo.current, self.demo.caption, self.demo.alpha, self.demo.saved = (
            None,
            '',
            0,
            [],
        )

    # 载入地图并启动指定演示时间线。
    def playDemo(self, key):
        demo_definition = next(
            (
                demo_definition
                for demo_definition in self.demos
                if demo_definition['key'] == key
            ),
            None,
        )

        if demo_definition is None:
            raise ValueError('Unknown demo: ' + key)

        self.stopDemo()
        self.loadMap(demo_definition['scene'])

        render_settings = self.app.settings
        self.demo.freeze = render_settings.freezeTime

        # 退出演示时恢复临时设置，避免编排参数污染后续实验
        self.demo.saved = [
            (key, render_settings.v[key]) for key, _ in demo_definition['settings']
        ]

        for key, value in demo_definition['settings']:
            render_settings.set(key, value)

        render_settings.freezeTime, render_settings.timeOfDay = (
            True,
            demo_definition['timeOfDay'],
        )
        self.app.paused = False

        demo_definition['steps'].sort(key=lambda entry: entry[0])

        self.demo.t = 0
        self.demo.next = 0
        self.demo.current = demo_definition

    # 执行演示或主页时间线中的动作集合。
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

    # 推进演示事件、相机与字幕状态。
    def updateDemo(self, delta):
        demo_definition = self.demo.current

        if demo_definition is None:
            return

        self.demo.t += delta
        playback_time = self.demo.t

        # 补齐本帧跨过的事件，避免低帧率时漏掉时间线动作
        while (
            self.demo.next < len(demo_definition['steps'])
            and demo_definition['steps'][self.demo.next][0] <= playback_time
        ):
            self.replay(demo_definition['steps'][self.demo.next][1])

            self.demo.next += 1

        if demo_definition['cam']:
            keyframe_index = 0

            while (
                keyframe_index + 1 < len(demo_definition['cam'])
                and demo_definition['cam'][keyframe_index + 1][0] <= playback_time
            ):
                keyframe_index += 1

            start_view, end_view = (
                demo_definition['cam'][keyframe_index],
                demo_definition['cam'][
                    min(keyframe_index + 1, len(demo_definition['cam']) - 1)
                ],
            )
            transition_duration = min(1.6, max(end_view[0] - start_view[0], 0.01))

            if end_view[0] > start_view[0]:
                transition_start = end_view[0] - transition_duration
                transition_elapsed = playback_time - transition_start
                transition_fraction = clamp(
                    transition_elapsed / transition_duration,
                    0,
                    1,
                )

            else:
                transition_fraction = 0

            transition_fraction = (
                transition_fraction
                * transition_fraction
                * (3 - 2 * transition_fraction)
            )

            camera_center = [
                start_view[axis]
                + (end_view[axis] - start_view[axis]) * transition_fraction
                for axis in (1, 2)
            ]
            camera_zoom = (
                start_view[3] + (end_view[3] - start_view[3]) * transition_fraction
            )

            self.app.camera.setView(camera_center, camera_zoom)

        self.demo.caption, self.demo.alpha = '', 0

        for caption_start, caption_duration, caption, *_ in demo_definition['captions']:
            if (
                playback_time >= caption_start
                and playback_time < caption_start + caption_duration
            ):
                self.demo.caption = caption
                self.demo.alpha = clamp(
                    min(
                        playback_time - caption_start,
                        caption_start + caption_duration - playback_time,
                    )
                    / 0.4,
                    0,
                    1,
                )

        if playback_time >= demo_definition['length']:
            self.stopDemo()

    # 载入地图并重置世界及光照历史。
    def loadMap(self, key, world_name=''):
        app, gpu = self.app, self.gpu
        self.sceneRevision += 1
        self.titleElapsed = 0
        app.probe, app.probePoint = dict(valid=False), None
        if key == 'void':
            # 内置 empty 地图有石地板。这里按格子格式写入空气编号、环境温度和两个零状态字。
            cell_count = app.W * app.H
            air_cell = struct.pack('<IfII', 0, app.sim.settings.ambient, 0, 0)
            cells = air_cell * cell_count
            background = bytes(cell_count * 4)
            # 丢弃上一张地图积压的模拟命令，让新建的空世界从干净的状态开始。
            app.commands.pending.clear()
            app.worldName = world_name
        else:
            cells = self.host.read_file('maps/' + key + '.cells.gz')
            background = self.host.read_file('maps/' + key + '.bg.gz')
            app.worldName = ''
        app.currentMap, app.currentBackground = key, background

        app.sim.upload(cells)
        app.render.uploadBackground(background)
        app.rigid.clear()
        app.rigid.onCells(cells)

        app.bodify = False
        app.time = 0
        app.accum = 0

        app.camera.fit()

        # 切图后重置光照历史，避免新地图混入上一场景的余光
        for pair in (
            app.render.fluence,
            app.render.day,
            app.render.beamTex,
            app.render.beamDir,
            app.render.sub,
            app.render.chA,
            app.render.chB,
        ):
            gpu.clearTexture(pair.read)
            gpu.clearTexture(pair.write)

        for texture in (app.render.ldir, *app.render.cascades, app.render.upperAvg):
            gpu.clearTexture(texture)

        gpu.writeBuffer(app.render.exposureBuf, 0, np.asarray([0, 0, 0, 1], '<f4'))

        app.render.frame = 0
        app.render.lastTime = 0
        app.settings.timeOfDay = 9.5 if key == 'titlelab' else 10

        self.observation.recordReset('load', key)

    # 按原有节奏推进主页背景编排。
    def updateTitle(self, delta):
        if self.app.currentMap != 'titlelab':
            return

        self.app.camera.center = [self.app.W / 2, self.app.H / 2]

        # 主页编排依赖双次计时，合并会改变原版动作触发时刻
        self.titleElapsed += delta
        previous = self.titleElapsed
        self.titleElapsed += delta

        for time, actions in self.titleSteps:
            if time > previous and time <= self.titleElapsed:
                self.replay(actions)

        if self.titleElapsed >= 22:
            self.loadMap('titlelab')

    # 按既有操作协议修改游戏控制状态。
    def action(self, action):
        app = self.app
        epoch_before, tick_at_acceptance = self.observation.worldEpoch, app.sim.tick
        action_type, handled = action['type'], True

        if action_type == 'load':
            self.stopDemo()
            self.loadMap(action['map'], action.get('world_name', ''))

        elif action_type == 'demo':
            self.playDemo(action['key'])

        elif action_type == 'demo_stop':
            self.stopDemo()

        elif action_type == 'pause':
            app.paused = bool(action['value'])

        elif action_type == 'step':
            app.steps += 1

        elif action_type == 'speed':
            app.speed = action['value']

        elif action_type == 'time':
            app.settings.timeOfDay = action['value']

        elif action_type == 'setting':
            app.settings.set(action['key'], action['value'])

        elif action_type == 'debug':
            app.render.mode = action['value']

        elif action_type == 'resize':
            app.camera.screen = [action['width'], action['height']]

            app.camera.fit()

            # 视图尺寸对齐8像素，满足渲染工作组的整块布局
            height = int(clamp(app.settings.n('ViewHeight'), 270, 2160)) & -8
            width = math.floor(height * action['width'] / action['height'] + 0.5) & -8

            app.render.setViewSize(max(64, width), height)

        elif action_type == 'fit':
            app.camera.fit()

        elif action_type == 'pan':
            app.camera.panBy(action['x'], action['y'])

        elif action_type == 'zoom':
            app.camera.zoomBy(action['x'], action['y'], action['factor'])

        elif action_type == 'yaw':
            app.camera.turn(action['value'])

        elif action_type == 'probe':
            app.probePoint = dict(
                screen_x=action['x'],
                screen_y=action['y'],
                request_id=action.get('request_id', 0),
            )

        elif action_type == 'paint':
            self.queuePaintCommand(action)

        elif action_type == 'clear':
            app.commands.add(
                dict(
                    type=7,
                    **{'from': [0, 0], 'to': [0, 0]},
                    radius=0,
                )
            )
            app.rigid.clear()
            self.observation.recordReset('clear_queued', app.currentMap)

        elif action_type == 'save':
            self.host.save_state(
                app.currentMap,
                app.settings.timeOfDay,
                self.host.read_texture(app.sim.cells.read.id),
                app.currentBackground,
                world_name=app.worldName,
            )

        elif action_type == 'restore':
            saved = json.loads(self.host.load_saved_info())
            cells = self.host.saved['cells.bin']

            app.sim.upload(cells)

            app.currentBackground = self.host.saved['background.bin']

            app.render.uploadBackground(app.currentBackground)
            self.stopDemo()

            self.sceneRevision += 1
            app.currentMap, app.settings.timeOfDay = saved['map'], saved['time']
            # 旧存档可能只有地图编号，缺少世界名称时仍可按原地图恢复。
            app.worldName = saved.get('world_name', '')

            # 存档保存格子材料，刚体需由恢复后的格子重新建立
            app.rigid.clear()
            app.rigid.onCells(cells)
            self.observation.recordReset('restore', app.currentMap)

        else:
            handled = False

        self.observation.recordAction(action, epoch_before, tick_at_acceptance, handled)

    # 将屏幕笔刷请求转成世界格子命令。
    def queuePaintCommand(self, action):
        app = self.app
        tool_id = action['tool']
        command_type = {2: 2, 3: 3, 4: 4, 5: 5, 6: 6}.get(tool_id, 1)

        if tool_id == 5:
            command_material = app.sim.fireId

        else:
            command_material = action['material']

        if tool_id == 6:
            brush_radius = action['radius'] * 1.5 + 4

        else:
            brush_radius = action['radius']

        brush_shape = action.get('shape', 0)
        overwrite_material = bool(action.get('overwrite', False))

        if tool_id == 1:
            spray_amount = 0.06

        elif tool_id == 5:
            spray_amount = 0.5

        else:
            spray_amount = 1

        if tool_id in (3, 4):
            command_strength = 40

        elif tool_id == 6:
            command_strength = 1.2

        else:
            command_strength = 0

        brush_command = dict(
            type=command_type,
            material=command_material,
            radius=brush_radius,
            shape=brush_shape,
            overwrite=overwrite_material,
            spray=spray_amount,
            strength=command_strength,
        )

        brush_command['from'] = app.camera.screenToCell(action['x0'], action['y0'])
        brush_command['to'] = app.camera.screenToCell(action['x1'], action['y1'])

        app.commands.add(brush_command)

        if tool_id <= 1 and app.materials[action['material']]['flags'] & 256:
            app.bodify = True

    # 协调本帧模拟、渲染、探针与观测边界。
    def frame(self, delta=1 / 60, forced_ticks=-1):
        frame_started = time.perf_counter()
        app = self.app

        self.observation.beginFrame(app, delta, forced_ticks)

        app.time += delta

        self.updateTitle(delta)
        self.updateDemo(delta)

        step_count = 0

        if not app.paused:
            # 累积小数步数，让模拟速率独立于显示帧率
            app.accum += delta * 60 * app.speed
            step_count = math.floor(app.accum)
            app.accum -= step_count

            if step_count > 2:
                # 限制补算步数，避免卡顿后集中追帧进一步阻塞模拟
                step_count, app.accum = 2, 0

        step_count += app.steps
        app.steps = 0

        if forced_ticks >= 0:
            step_count = forced_ticks

        self.updateCameraAndDaylight(delta)
        self.simulateAndRender(step_count)
        self.updatePointerProbe()

        # 帧尾统一交付归属数据，避免下一帧混用不同边界的读回
        while self.gpu.jobs:
            self.gpu.jobs.pop(0)()

        self.observation.endFrame(app)

        frame_state = self.serializeFrameState()
        pixels = self.host.read_texture(frame_state['texture'])
        frame_state['frame_ms'] = (time.perf_counter() - frame_started) * 1000
        frame_state['dispatches'] = self.host.dispatches

        return Frame(pixels, frame_state['width'], frame_state['height'], frame_state)

    # 同步相机参数并推进昼夜控制状态。
    def updateCameraAndDaylight(self, delta):
        app, settings, camera = self.app, self.app.settings, self.app.camera
        camera.tiltTopDeg = settings.effectiveTilt
        camera.tiltBottomDeg = settings.n('TiltBottom') if settings.voxel else 0
        camera.tiltCurve, camera.yawMaxDeg = (
            settings.n('TiltCurve'),
            settings.effectiveYaw,
        )
        camera.applyYaw, camera.fovYDeg = settings.voxel, settings.n('FovY')

        camera.update(delta)

        if settings.b('DayCycleOn') and not settings.freezeTime and not app.paused:
            settings.timeOfDay = (
                settings.timeOfDay
                + delta * 24 / max(settings.n('DayLength') * 60, 1) * app.speed
            ) % 24

        settings.frameParallax = [
            -(camera.center[0] - 256) / 256 * settings.n('Parallax')
            + math.tan(camera.userYaw * math.pi / 180) * 0.5,
            -(camera.center[1] - 144) / 144 * settings.n('Parallax'),
        ]

    # 协调刚体、网格、渲染及帧末GPU读回。
    def simulateAndRender(self, ticks):
        app, gpu = self.app, self.gpu
        rigid_packet = app.rigid.update(ticks / 60, ticks == 0)

        gpu.begin()
        app.bodyGpu.preStep(app.sim, rigid_packet)

        for step_index in range(ticks):
            # 追赶多步时只消费一次笔刷，避免同一输入被重复施加
            frame_commands = app.commands if step_index == 0 else None
            grid_boundary = self.observation.beginGridBoundary(
                app, frame_commands, 'grid_step', step_index
            )

            app.sim.step(frame_commands)
            self.observation.endGridBoundary(grid_boundary, app)

        if ticks == 0 and app.commands.count:
            # 暂停时仍应用编辑命令，保证画笔操作即时反馈
            grid_boundary = self.observation.beginGridBoundary(
                app, app.commands, 'paused_commands', 0
            )

            app.sim.applyCommandsOnly(app.commands)
            self.observation.endGridBoundary(grid_boundary, app)

        app.bodyGpu.postStep(
            app.sim, rigid_packet.frame, app.rigid.onOccupancy, app.rigid.onOwners
        )

        app.sim.lightTex, app.sim.daylightTex = (
            app.render.fluenceTex,
            app.render.daylightTex,
        )

        app.render.render(app.sim, app.time, app.camera.view)

        if app.render.mode == 0:
            output_texture = app.render.output

        else:
            output_texture = app.render.debugOutput

        # 同一提交汇总读回，减少统计与画面之间的同步等待
        self.host.queue_frame_readbacks(
            app.sim.statsBuf.id,
            SimulationStatistics.SizeBytes,
            app.bodyGpu.occ.id,
            app.W * app.H // 4,
            app.bodyGpu.owner.id,
            app.bodyGpu.atlasUsed * 4,
            output_texture.id,
        )
        gpu.submit()

        if app.bodify:
            app.bodify = False

            app.rigid.onCells(self.host.read_texture(app.sim.cells.read.id))

        app.stats.parse(
            self.host.read_buffer(
                app.sim.statsBuf.id, 0, SimulationStatistics.SizeBytes
            )
        )
        self.observation.recordExplosions(app.stats.explosions)

        for explosion_event in app.stats.explosions:
            app.camera.addShake(
                clamp(explosion_event[3] * explosion_event[2] * 0.08, 0.2, 2.5)
            )
            app.rigid.blast(explosion_event)

    # 读取待查询格子的真实材料与温度。
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
                app.probe = dict(
                    request,
                    valid=math.isfinite(temperature),
                    x=x,
                    y=y,
                    material=material & 255,
                    temp=temperature,
                )

        app.probePoint = None

    # 组装界面和最终呈现所需的帧状态。
    def serializeFrameState(self):
        app, render_settings, camera, statistics = (
            self.app,
            self.app.settings,
            self.app.camera,
            self.app.stats,
        )

        if app.render.mode == 0:
            output_texture = app.render.output

        else:
            output_texture = app.render.debugOutput

        return dict(
            texture=output_texture.id,
            width=output_texture.width,
            height=output_texture.height,
            tick=app.sim.tick,
            time=app.time,
            day=render_settings.timeOfDay,
            bodies=len(app.rigid.bodies),
            map=app.currentMap,
            world_name=app.worldName,
            title_elapsed=self.titleElapsed,
            paused=app.paused,
            probe=dict(app.probe),
            events=statistics.events.tolist(),
            explosions=statistics.explosions,
            histogram=statistics.histogram.tolist(),
            reactions=statistics.reactionCount.tolist(),
            ignite=statistics.igniteCount.tolist(),
            phase_hi=statistics.phaseHi.tolist(),
            phase_lo=statistics.phaseLo.tolist(),
            scene_revision=self.sceneRevision,
            frame=app.render.frame,
            demo=self.demo.current['key'] if self.demo.current else '',
            demo_caption=self.demo.caption,
            demo_alpha=self.demo.alpha,
            vignette=render_settings.n('Vignette'),
            grain=render_settings.n('Grain'),
            chroma=render_settings.n('Chroma')
            * min(vector_length(*camera.shake) * 0.4 + 0.15, 1),
            zoom=camera.zoom,
            camera_center=list(camera.view.center),
            camera_size=list(camera.screen),
            view_mode=app.render.mode,
        )

    # 维护现有观测与地图工具调用入口。
    def call(self, name, *args):
        methods = {
            'loadMap': self.loadMap,
            'setWorldObservationEnabled': self.observation.setEnabled,
            'describeWorldObservation': lambda: json.dumps(
                self.observation.describe(self), ensure_ascii=False
            ),
        }

        return methods[name](*args)

    # 取得CPU侧持有的指定观测字段。
    def read_cpu_field(self, name):
        if name != 'background_rgba':
            raise KeyError(name)

        return bytes(self.app.currentBackground)

    # 为验证入口设置相机中心与缩放。
    def set_camera_view(self, center, zoom):
        self.app.camera.setView(center, zoom)

    # 解析验证工具使用的只读资源路径。
    def evaluate(self, path):
        """Compatibility for validation tools reading resource paths; no code execution."""

        # 路径校验维持旧工具的查询接口，避免将输入作为代码执行
        if not re.fullmatch(r'app(?:\.[A-Za-z_][A-Za-z_0-9]*|\[\d+\])*', path):
            raise ValueError(
                'Use the Python app objects for operations; only resource paths can be inspected'
            )

        value = self.app

        for attribute, index in re.findall(
            r'\.([A-Za-z_][A-Za-z_0-9]*)|\[(\d+)\]', path[3:]
        ):
            value = getattr(value, attribute) if attribute else value[int(index)]

        return value

    # 按一次性清理约定释放世界GPU资源。
    def close(self):
        if not self.closed:
            self.host.close()

            self.closed = True
