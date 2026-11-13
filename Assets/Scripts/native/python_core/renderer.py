"""Radiance cascades, view projection and postprocessing, scheduled in Python."""

import math

import numpy as np

from .gpu import Bindings, ComputeShader, DoubleBuffer, Parameters
from .settings import WorldCamera, clamp


# 计算指定光照级联覆盖的距离区间。
def cascade_range(index):
    return 2 * (4**index - 1) / 3, 2 * (4 ** (index + 1) - 1) / 3


class RenderView:
    # 初始化单个视图的画面和后处理资源。
    def __init__(self, gpu, width, height, exposure, uniform):
        self.w, self.h = width, height
        self.exposure, self.ubo, self.lastTime = exposure, uniform, 0
        self.hdr = gpu.createTexture(width, height, 'rgba16float', 'view_hdr')
        self.dof = gpu.createTexture(width, height, 'rgba16float', 'view_dof')
        self.cost = gpu.createTexture(width, height, 'rgba16float', 'cost_view')
        self.output = gpu.createTexture(width, height, 'rgba8unorm', 'final')
        self.bloomDown, self.bloomUp = [None] * 6, [None] * 5

        for level in range(1, 6):
            self.bloomDown[level] = gpu.createTexture(
                max(width >> level, 1),
                max(height >> level, 1),
                'rgba16float',
                'bloom_d' + str(level),
            )

            if level < 5:
                self.bloomUp[level] = gpu.createTexture(
                    max(width >> level, 1),
                    max(height >> level, 1),
                    'rgba16float',
                    'bloom_u' + str(level),
                )

        gpu.clearTexture(self.hdr)

    # 创建独立视图及其曝光与参数资源。
    @classmethod
    def create(cls, gpu, width, height):
        exposure = gpu.createStorageBuffer(
            16, np.asarray([0, 0, 0, 1], '<f4'), 'exposure_extra'
        )
        uniform = gpu.createUniformBuffer(464, 'render_params_extra')

        return cls(gpu, max(64, width & -8), max(64, height & -8), exposure, uniform)

    # 按共享关系释放当前视图的渲染资源。
    def destroy(self, shared=False):
        for texture in [
            self.hdr,
            self.dof,
            self.cost,
            self.output,
            *self.bloomDown,
            *self.bloomUp,
        ]:
            if texture is not None:
                texture.destroy()

        # 主视图共享曝光与参数缓冲，视口重建时由渲染器继续持有
        if not shared:
            self.exposure.destroy()
            self.ubo.destroy()


class WorldRenderer:
    OCCLUSION_PASSES = {'bloom_down', 'bloom_up', 'tonemap', 'front_fog', 'view3d'}

    # 初始化光照、视图与后处理资源。
    def __init__(
        self,
        gpu,
        width,
        height,
        settings,
        grading_lut,
        view_width=1536,
        view_height=864,
    ):
        self.gpu, self.width, self.height, self.settings = gpu, width, height, settings
        self.mode = 0
        self.debugCascade = 0
        self.spacing, self.frame, self.lastTime = 1, 0, 0
        self.lightHalfRate, self.midHalf = False, True
        self.farFrom, self.fixBelow = 2, 3
        self.retired = []
        self.main = None
        self.upperAvg = None
        self.ldir = None
        self.fluence = None
        self.chA = None
        self.chB = None
        self.cascades, self.flMips = [], []
        diagonal = math.sqrt(width * width + height * height)
        self.cascadeCount = next(
            (
                count
                for count in range(3, 8)
                if cascade_range(count - 1)[1] >= diagonal
                and width % (1 << count) == 0
                and height % (1 << count) == 0
            ),
            None,
        )

        if self.cascadeCount is None:
            raise ValueError('World size is not supported by the cascade layout')

        self.debugOutput = self.texture(width, height, 'debug_out', 'rgba8unorm')
        self.background = self.texture(width, height, 'background', 'rgba8uint')
        self.debugPass = ComputeShader(gpu, 'render/debug_view.comp')
        self.albedo = self.texture(width, height, 'albedo')
        self.emissive = self.texture(width, height, 'emissive')
        self.rcsrc = self.texture(width, height, 'rc_src')
        self.gaux = self.texture(width, height, 'gaux')
        self.l0s, self.l0t = self.texture(width, height, 'layer0_s'), self.texture(
            width, height, 'layer0_t'
        )
        self.mips, self.extMips = [self.rcsrc], [self.texture(width, height, 'rc_ext')]

        for level in range(1, 5):
            self.mips.append(
                self.texture(width >> level, height >> level, 'rc_mip' + str(level))
            )
            self.extMips.append(
                self.texture(width >> level, height >> level, 'rc_ext_mip' + str(level))
            )

        self.allocLight(1)

        self.godrays = self.texture(width // 2, height // 2, 'godrays')
        self.exposureBuf = gpu.createStorageBuffer(
            16, np.asarray([0, 0, 0, 1], '<f4'), 'exposure'
        )
        self.ubo = gpu.createUniformBuffer(464, 'render_params')
        self.lut = gpu.createTexture(32, 32, 'rgba16float', 'grading_lut', 32)

        gpu.writeTexture(self.lut, grading_lut)

        passes = [
            'gbuffer',
            'rc_mips',
            'rc_cascade',
            'rc_resolve',
            'composite',
            'bloom_down',
            'bloom_up',
            'exposure',
            'tonemap',
            'godrays',
            'downsample',
            'view3d',
            'occ_field',
            'dof',
            'subsurface',
            'beam_waves',
            'beam_probe',
            'light_prep',
            'beam_blur',
            'window_shafts',
            'front_fog',
            'fog_backlight',
            'daylight',
            'view_cells',
            'rc_avg',
        ]
        self.p = {
            name: ComputeShader(gpu, 'render/' + name + '.comp') for name in passes
        }
        self.occ = self.texture(width, height, 'occ_field')
        self.side = self.texture(width, height, 'side_colour')
        self.bgsm = self.texture(width, height, 'bg_smooth')
        self.sunHit = gpu.createStorageBuffer(640 * 4, None, 'sun_hits')
        self.lampProbe = gpu.createStorageBuffer(
            math.ceil(((width + 1) >> 1) / 8) * math.ceil(((height + 1) >> 1) / 8) * 16,
            None,
            'lamp_probes',
        )
        self.rcOccBuf = gpu.createStorageBuffer(512, None, 'rc_occupancy')
        self.dayCells = self.texture(width, height, 'day_cells', 'rgba32uint')
        self.beamBuf = gpu.createStorageBuffer(
            width // 2 * (height // 2) * 20, None, 'mirror_beams'
        )
        self.shafts = self.texture(width, height, 'window_shafts')
        self.day = self.pair(width, height, 'daylight')
        self.fogTex = self.texture(width, height, 'front_fog')
        self.backlight = self.texture(width, height, 'fog_backlight')
        self.cellShade = self.texture(width, height * 3, 'cell_shade', 'rgba32float')
        self.matCost = gpu.createStorageBuffer(1040, None, 'material_cost')
        self.beamTex = self.pair(width // 2, height // 2, 'beam')
        self.beamDir = self.pair(width // 2, height // 2, 'beam_dir')
        self.glossA, self.glossB = self.texture(width, height, 'gloss_a'), self.texture(
            width, height, 'gloss_b'
        )
        self.sub = self.pair(width, height, 'subsurface')

        for pair in (
            self.fluence,
            self.day,
            self.beamTex,
            self.beamDir,
            self.sub,
            self.chA,
            self.chB,
        ):
            gpu.clearTexture(pair.read)
            gpu.clearTexture(pair.write)

        gpu.clearTexture(self.ldir)
        self.setViewSize(view_width, view_height)

    # 创建具有安全最小尺寸的渲染纹理。
    def texture(self, width, height, label, format='rgba16float'):
        return self.gpu.createTexture(
            max(int(width), 1), max(int(height), 1), format, label
        )

    # 创建用于相邻阶段交换的纹理资源对。
    def pair(self, width, height, label):
        return DoubleBuffer(
            self.texture(width, height, label + '_a'),
            self.texture(width, height, label + '_b'),
        )

    # 取得主视图的最终输出纹理。
    @property
    def output(self):
        return self.main.output

    # 取得主视图当前渲染宽度。
    @property
    def viewW(self):
        return self.main.w if self.main else 0

    # 取得主视图当前渲染高度。
    @property
    def viewH(self):
        return self.main.h if self.main else 0

    # 取得当前可用的间接光照纹理。
    @property
    def fluenceTex(self):
        return self.fluence.read

    # 取得当前可用的日光纹理。
    @property
    def daylightTex(self):
        return self.day.read

    # 读取当前光照采样的网格间距。
    @property
    def lightSpacing(self):
        return self.spacing

    # 在间距变化时重建光照资源。
    def setLightSpacing(self, spacing):
        if spacing != self.spacing:
            self.allocLight(spacing)

    # 创建新光场并延迟回收旧光照资源。
    def allocLight(self, spacing):
        retired = [*self.cascades, self.upperAvg, *self.flMips[1:], self.ldir]

        for pair in (self.fluence, self.chA, self.chB):
            if pair:
                retired.extend((pair.read, pair.write))

        retired = [texture for texture in retired if texture is not None]

        if retired:
            # 延迟释放旧光场，避免在途帧引用失效的纹理
            self.retired.append((retired, self.frame + 3))

        self.spacing = spacing
        width, height = self.width // spacing, self.height // spacing
        self.cascades = [
            self.texture(width * 4, height * 4, 'cascade' + str(index))
            for index in range(self.cascadeCount)
        ]
        self.upperAvg = self.texture(
            width * 2, height * 2, 'cascade_upper_avg', 'rgba32float'
        )
        self.fluence = self.pair(width, height, 'fluence')
        self.flMips = [self.fluence.read] + [
            self.texture(width >> level, height >> level, 'fluence_mip' + str(level))
            for level in range(1, 5)
        ]
        self.ldir = self.texture(width, height, 'light_dir')
        self.chA, self.chB = self.pair(width, height, 'ch_a'), self.pair(
            width, height, 'ch_b'
        )

        for pair in (self.fluence, self.chA, self.chB):
            self.gpu.clearTexture(pair.read)
            self.gpu.clearTexture(pair.write)

        self.gpu.clearTexture(self.ldir)

    # 选择与采样间距对应的辐照度层级。
    def fl(self, level):
        return self.flMips[max(level - (self.spacing >> 1), 0)]

    # 上传地图背景的材质数据。
    def uploadBackground(self, data):
        self.gpu.writeTexture(self.background, data)

    # 按渲染对齐约束调整主视图尺寸。
    def setViewSize(self, width, height):
        width, height = max(64, int(width) & -8), max(64, int(height) & -8)

        if self.main and width == self.main.w and height == self.main.h:
            return False

        if self.main:
            self.main.destroy(True)

        self.main = RenderView(self.gpu, width, height, self.exposureBuf, self.ubo)

        return True

    # 为当前世界构造默认渲染视图。
    def defaultCamera(self):
        camera = WorldCamera()
        camera.center = [self.width / 2, self.height / 2]
        camera.screen = [self.viewW, self.viewH]
        camera.zoom = min(self.viewW / self.width, self.viewH / self.height)
        camera.tiltTopDeg = self.settings.effectiveTilt

        if self.settings.b('Enable3D'):
            camera.tiltBottomDeg = self.settings.n('TiltBottom')

        else:
            camera.tiltBottomDeg = 0

        camera.tiltCurve = self.settings.n('TiltCurve')
        camera.fovYDeg = self.settings.n('FovY')

        camera.updateView()

        return camera.view

    # 补齐遮挡绑定并派发指定渲染阶段。
    def dispatch(self, name, bindings, parameters, width, height, *, view_ubo=None):
        if self.gpu.host.lighting_corrections and name in self.OCCLUSION_PASSES:
            # 后处理也需读取材质遮挡，避免模糊光晕穿过实体墙面
            bindings.image(30, self.extMips[0])
            bindings.image(31, self.emissive)

            if name not in ('front_fog', 'view3d'):
                bindings.ubo(32, view_ubo or self.ubo)

        self.p[name].dispatch(bindings, parameters, width, height)

    # 生成世界画面及所选调试视图。
    def render(self, grid, time, camera=None):
        self.renderFinal(grid, time, camera or self.defaultCamera())

        if self.mode == 0:
            return

        debug_texture, debug_channel, debug_gain = grid.fluidVel.read, 0, 1

        if self.mode in (1, 2, 3, 4, 5, 10):
            debug_mode = {1: 0, 2: 1, 3: 2, 4: 3, 5: 4, 10: 6}[self.mode]

            if self.mode == 4:
                debug_gain = 1.5

            if self.mode == 5:
                debug_texture = grid.medium.read

        else:
            debug_mode = 5
            choices = {
                6: self.fluence.read,
                7: self.cascades[clamp(self.debugCascade, 0, self.cascadeCount - 1)],
                8: self.rcsrc,
                9: self.rcsrc,
            }
            debug_texture = choices.get(self.mode, self.l0s)

            if self.mode == 9:
                debug_channel, debug_gain = 1, 0.5

        debug_pass_bindings = Bindings()

        debug_pass_bindings.image(0, grid.cells.read)
        debug_pass_bindings.buffer(1, grid.materialsBuf)
        debug_pass_bindings.image(2, self.debugOutput)
        debug_pass_bindings.sampler(3, self.gpu.linearClamp, debug_texture)
        self.debugPass.dispatch(
            debug_pass_bindings,
            Parameters(
                i0x=self.width,
                i0y=self.height,
                i1x=debug_mode,
                i1y=debug_channel,
                f0x=debug_gain,
            ),
            self.width,
            self.height,
        )

    # 调度光照与材质计算后生成主视图。
    def renderFinal(self, grid, time, camera):
        gpu, settings = self.gpu, self.settings
        world_width, world_height = self.width, self.height
        delta = clamp(time - self.lastTime, 0, 0.1)
        self.lastTime = time

        while self.retired and self.retired[0][1] <= self.frame:
            for texture in self.retired.pop(0)[0]:
                texture.destroy()

        gpu.writeBuffer(
            self.ubo,
            0,
            settings.toUbo(
                time,
                delta,
                world_width,
                world_height,
                self.cascadeCount,
                camera,
                self.viewW,
                self.viewH,
            ),
        )

        linear_sampler = gpu.linearClamp
        mirror_strength = settings.n('MirrorBeams')
        lamp_strength = settings.n('LampBeams')

        # 交错更新远场与介质，利用历史光照分摊每帧计算开销
        is_even_frame = not self.frame & 1
        update_lighting = not self.lightHalfRate or is_even_frame
        update_medium = not (self.lightHalfRate or self.midHalf) or not is_even_frame
        update_far_cascades = self.lightHalfRate or is_even_frame

        if update_medium:
            gpu.clearBuffer(self.beamBuf)

            direction = settings.daylightDir()
            probe_columns = math.ceil(((world_width + 1) >> 1) / 8)
            probe_rows = math.ceil(((world_height + 1) >> 1) / 8)
            world_diagonal = math.sqrt(
                world_width * world_width + world_height * world_height
            )
            beam_radius = world_diagonal * 0.5 + 2
            beam_sample_count = math.floor(2 * beam_radius) + 1
            beam_steps = math.ceil(beam_sample_count / 32)
            parameters = Parameters(
                i0x=world_width,
                i0y=world_height,
                i0z=beam_steps,
                i1x=probe_columns,
                i1y=probe_rows,
                i1z=int(mirror_strength > 0),
                i1w=int(lamp_strength > 0),
                f0x=mirror_strength,
                f0y=settings.n('MirrorBeamRange'),
                f1x=direction[0],
                f1y=direction[1],
                f1z=lamp_strength,
            )
            bindings = Bindings()

            bindings.image(0, grid.cells.read)
            bindings.buffer(1, grid.materialsBuf)
            bindings.image(2, self.albedo)
            bindings.image(3, self.emissive)
            bindings.image(4, self.gaux)
            bindings.sampler(5, linear_sampler, self.fluence.read)
            bindings.sampler(6, linear_sampler, self.ldir)
            bindings.buffer(7, self.beamBuf)
            bindings.sampler(8, linear_sampler, self.day.read)
            bindings.sampler(9, linear_sampler, self.beamTex.read)
            bindings.sampler(10, linear_sampler, grid.medium.read)
            bindings.buffer(11, self.sunHit)
            bindings.buffer(12, self.lampProbe)

            if mirror_strength > 0:
                gpu.clearBuffer(self.sunHit)

            mirror_probes = (
                math.ceil(640 * beam_steps / 256) if mirror_strength > 0 else 0
            )
            lamp_probes = probe_columns * probe_rows if lamp_strength > 0 else 0
            probes = mirror_probes + lamp_probes

            if probes > 0:
                self.dispatch('beam_probe', bindings, parameters, probes * 256, 1)

            if mirror_strength > 0:
                mirror_waves = 80 + math.ceil(world_width / 8) * math.ceil(
                    world_height / 8
                )

            else:
                mirror_waves = 0

            lamp_waves = probe_columns * probe_rows * 8 if lamp_strength > 0 else 0
            waves = mirror_waves + lamp_waves

            if waves > 0:
                self.dispatch('beam_waves', bindings, parameters, waves * 8, 8)

            beam_blur_bindings = Bindings()

            beam_blur_bindings.buffer(0, self.beamBuf)
            beam_blur_bindings.image(1, self.beamTex.read)
            beam_blur_bindings.image(2, self.beamTex.write)
            beam_blur_bindings.image(3, self.beamDir.write)
            beam_blur_bindings.image(4, self.beamDir.read)
            self.dispatch(
                'beam_blur',
                beam_blur_bindings,
                Parameters(
                    i0x=world_width // 2,
                    i0y=world_height // 2,
                    f0x=0.07,
                ),
                world_width // 2,
                world_height // 2,
            )
            self.beamTex.swap()
            self.beamDir.swap()

        gbuffer_bindings = Bindings()

        gbuffer_bindings.image(0, grid.cells.read)
        gbuffer_bindings.buffer(1, grid.materialsBuf)
        gbuffer_bindings.sampler(2, linear_sampler, grid.medium.read)
        gbuffer_bindings.sampler(3, linear_sampler, self.fluence.read)
        gbuffer_bindings.ubo(4, self.ubo)
        gbuffer_bindings.image(5, self.albedo)
        gbuffer_bindings.image(6, self.emissive)
        gbuffer_bindings.image(7, self.rcsrc)
        gbuffer_bindings.image(8, self.gaux)
        gbuffer_bindings.image(9, self.background)
        gbuffer_bindings.image(10, self.extMips[0])
        gbuffer_bindings.sampler(11, linear_sampler, self.beamTex.read)
        gbuffer_bindings.sampler(12, linear_sampler, self.day.read)
        gbuffer_bindings.sampler(13, linear_sampler, self.ldir)
        gbuffer_bindings.image(14, self.glossA)
        self.dispatch(
            'gbuffer',
            gbuffer_bindings,
            Parameters(
                i0x=world_width,
                i0y=world_height,
                i0z=self.frame & 0x7FFFFFFF,
            ),
            world_width,
            world_height,
        )

        if update_lighting:
            for mip_level in range(1, 5):
                rc_mips_bindings = Bindings()

                rc_mips_bindings.image(0, self.mips[mip_level - 1])
                rc_mips_bindings.image(1, self.mips[mip_level])
                rc_mips_bindings.image(2, self.extMips[mip_level - 1])
                rc_mips_bindings.image(3, self.extMips[mip_level])
                self.dispatch(
                    'rc_mips',
                    rc_mips_bindings,
                    Parameters(
                        i0x=world_width >> mip_level, i0y=world_height >> mip_level
                    ),
                    world_width >> mip_level,
                    world_height >> mip_level,
                )

        gpu.clearBuffer(self.rcOccBuf)

        light_prep_bindings = Bindings()

        light_prep_bindings.image(0, self.glossA)
        light_prep_bindings.buffer(1, self.rcOccBuf)
        light_prep_bindings.image(2, self.albedo)
        light_prep_bindings.image(3, self.emissive)
        light_prep_bindings.image(4, self.background)
        light_prep_bindings.image(5, grid.cells.read)
        light_prep_bindings.image(6, self.dayCells)
        self.dispatch(
            'light_prep',
            light_prep_bindings,
            Parameters(
                i0x=world_width,
                i0y=world_height,
                i0z=world_width // 8,
                i0w=world_height // 8,
            ),
            world_width,
            world_height,
        )

        if update_lighting:
            # 从远到近求解级联，让近层可复用远层的入射光
            for cascade_index in range(self.cascadeCount - 1, -1, -1):
                if (
                    cascade_index >= self.farFrom
                    and not update_far_cascades
                    or not self.lightHalfRate
                    and cascade_index > self.farFrom
                    and self.frame & 3
                    != (0 if cascade_index == self.farFrom + 1 else 2)
                ):
                    continue

                mip_level = clamp(cascade_index - 1, 0, 4)
                near_distance, far_distance = cascade_range(cascade_index)
                parameters = Parameters(
                    i0x=world_width,
                    i0y=world_height,
                    i0z=cascade_index,
                    i0w=self.cascadeCount,
                    i1x=self.spacing << cascade_index,
                    i1y=4 << cascade_index,
                    i1z=int(
                        settings.b('BilinearFix') and cascade_index < self.fixBelow
                    ),
                    i1w=mip_level,
                    f0x=near_distance,
                    f0y=far_distance,
                    f0z=max(1, 1 << mip_level),
                )
                packed_width, packed_height = (
                    world_width // self.spacing * 4,
                    world_height // self.spacing * 4,
                )

                if cascade_index < self.cascadeCount - 1:
                    rc_avg_bindings = Bindings()

                    rc_avg_bindings.sampler(
                        0, gpu.nearestClamp, self.cascades[cascade_index + 1]
                    )
                    rc_avg_bindings.image(1, self.upperAvg)
                    self.dispatch(
                        'rc_avg',
                        rc_avg_bindings,
                        Parameters(
                            i0x=packed_width // 2,
                            i0y=packed_height // 2,
                            i1y=4 << cascade_index,
                        ),
                        packed_width // 2,
                        packed_height // 2,
                    )

                rc_cascade_bindings = Bindings()

                rc_cascade_bindings.sampler(0, linear_sampler, self.mips[mip_level])
                rc_cascade_bindings.image(1, self.upperAvg)
                rc_cascade_bindings.image(2, self.cascades[cascade_index])
                rc_cascade_bindings.ubo(3, self.ubo)
                rc_cascade_bindings.sampler(4, linear_sampler, self.extMips[mip_level])
                rc_cascade_bindings.sampler(5, gpu.nearestClamp, self.glossA)
                rc_cascade_bindings.buffer(6, self.rcOccBuf)
                self.dispatch(
                    'rc_cascade',
                    rc_cascade_bindings,
                    parameters,
                    packed_width,
                    packed_height,
                )

            light_width, light_height = (
                world_width // self.spacing,
                world_height // self.spacing,
            )
            rc_resolve_bindings = Bindings()

            rc_resolve_bindings.image(0, self.cascades[0])
            rc_resolve_bindings.image(1, self.fluence.read)
            rc_resolve_bindings.image(2, self.fluence.write)
            rc_resolve_bindings.image(3, self.ldir)
            rc_resolve_bindings.ubo(4, self.ubo)
            rc_resolve_bindings.image(5, self.chA.read)
            rc_resolve_bindings.image(6, self.chB.read)
            rc_resolve_bindings.image(7, self.chA.write)
            rc_resolve_bindings.image(8, self.chB.write)
            self.dispatch(
                'rc_resolve',
                rc_resolve_bindings,
                Parameters(
                    i0x=light_width,
                    i0y=light_height,
                    i1x=4,
                ),
                light_width,
                light_height,
            )
            self.fluence.swap()
            self.chA.swap()
            self.chB.swap()

            self.flMips[0] = self.fluence.read

            for mip_level in range(1, 5):
                mip_width, mip_height = max(light_width >> mip_level, 1), max(
                    light_height >> mip_level, 1
                )
                downsample_bindings = Bindings()

                downsample_bindings.image(0, self.flMips[mip_level - 1])
                downsample_bindings.image(1, self.flMips[mip_level])
                self.dispatch(
                    'downsample',
                    downsample_bindings,
                    Parameters(i0x=mip_width, i0y=mip_height),
                    mip_width,
                    mip_height,
                )

        parameters = Parameters(i0x=world_width, i0y=world_height)

        if update_medium:
            for _ in range(6):
                subsurface_bindings = Bindings()

                subsurface_bindings.image(0, grid.cells.read)
                subsurface_bindings.buffer(1, grid.materialsBuf)
                subsurface_bindings.image(2, self.albedo)
                subsurface_bindings.image(3, self.emissive)
                subsurface_bindings.image(4, self.gaux)
                subsurface_bindings.sampler(5, linear_sampler, self.fluence.read)
                subsurface_bindings.image(6, self.sub.read)
                subsurface_bindings.image(7, self.sub.write)
                self.dispatch(
                    'subsurface',
                    subsurface_bindings,
                    parameters,
                    world_width,
                    world_height,
                )
                self.sub.swap()

            direction = settings.daylightDir()
            daylight_bindings = Bindings()

            daylight_bindings.sampler(3, linear_sampler, grid.medium.read)
            daylight_bindings.image(4, self.day.write)
            daylight_bindings.ubo(5, self.ubo)
            daylight_bindings.buffer(7, grid.materialsBuf)
            daylight_bindings.image(8, self.day.read)
            daylight_bindings.image(10, self.dayCells)
            self.dispatch(
                'daylight',
                daylight_bindings,
                Parameters(
                    i0x=world_width,
                    i0y=world_height,
                    f0x=direction[0],
                    f0y=direction[1],
                    f0z=settings.daylightNow,
                    f0w=settings.n('DaylightRange'),
                ),
                world_width,
                world_height,
            )
            self.day.swap()

        composite_bindings = Bindings()

        composite_bindings.image(0, self.albedo)
        composite_bindings.image(1, self.emissive)
        composite_bindings.image(2, self.gaux)
        composite_bindings.sampler(3, linear_sampler, self.fluence.read)
        composite_bindings.sampler(4, linear_sampler, self.ldir)
        composite_bindings.sampler(5, linear_sampler, grid.medium.read)
        composite_bindings.image(6, grid.cells.read)
        composite_bindings.buffer(7, grid.materialsBuf)
        composite_bindings.ubo(8, self.ubo)
        composite_bindings.image(9, self.l0s)
        composite_bindings.image(10, self.l0t)
        composite_bindings.image(11, self.sub.read)
        composite_bindings.sampler(12, linear_sampler, self.day.read)
        composite_bindings.sampler(13, linear_sampler, self.beamTex.read)
        composite_bindings.sampler(14, linear_sampler, self.beamDir.read)
        composite_bindings.sampler(15, linear_sampler, self.chA.read)
        composite_bindings.sampler(16, linear_sampler, self.chB.read)
        self.dispatch(
            'composite', composite_bindings, parameters, world_width, world_height
        )

        godrays_bindings = Bindings()

        godrays_bindings.sampler(0, linear_sampler, self.rcsrc)
        godrays_bindings.image(1, self.background)
        godrays_bindings.sampler(2, linear_sampler, grid.medium.read)
        godrays_bindings.image(3, self.godrays)
        godrays_bindings.ubo(4, self.ubo)
        self.dispatch(
            'godrays',
            godrays_bindings,
            Parameters(
                i0x=world_width // 2,
                i0y=world_height // 2,
                i1x=world_width,
                i1y=world_height,
            ),
            world_width // 2,
            world_height // 2,
        )

        if settings.b('Enable3D') and (not self.lightHalfRate or is_even_frame):
            occ_field_bindings = Bindings()

            occ_field_bindings.image(0, self.l0s)
            occ_field_bindings.image(1, self.occ)
            occ_field_bindings.image(2, self.side)
            occ_field_bindings.image(3, self.background)
            occ_field_bindings.image(4, self.bgsm)
            self.dispatch(
                'occ_field', occ_field_bindings, parameters, world_width, world_height
            )

        if (
            settings.b('Enable3D')
            and not settings.b('VoxelExtrude')
            and (not self.lightHalfRate or not is_even_frame)
        ):
            # 雾光使用未跨墙模糊的光场，避免积分带入墙后亮度
            if gpu.host.lighting_corrections:
                backlight_levels = (self.fluence.read, self.fluence.read)

            else:
                backlight_levels = (self.fl(2), self.fl(3))

            fog_backlight_bindings = Bindings()

            fog_backlight_bindings.image(0, self.l0s)
            fog_backlight_bindings.image(1, self.l0t)
            fog_backlight_bindings.sampler(2, linear_sampler, backlight_levels[0])
            fog_backlight_bindings.sampler(3, linear_sampler, backlight_levels[1])
            fog_backlight_bindings.sampler(4, linear_sampler, self.day.read)
            fog_backlight_bindings.image(5, self.backlight)
            self.dispatch(
                'fog_backlight',
                fog_backlight_bindings,
                parameters,
                world_width,
                world_height,
            )

            front_fog_bindings = Bindings()

            front_fog_bindings.image(0, self.l0s)
            front_fog_bindings.image(1, self.l0t)
            front_fog_bindings.image(2, self.background)
            front_fog_bindings.sampler(3, linear_sampler, self.fl(2))
            front_fog_bindings.sampler(4, linear_sampler, self.fl(3))
            front_fog_bindings.image(5, self.fogTex)
            front_fog_bindings.ubo(6, self.ubo)
            front_fog_bindings.sampler(7, linear_sampler, self.day.read)
            front_fog_bindings.image(8, self.backlight)
            self.dispatch(
                'front_fog', front_fog_bindings, parameters, world_width, world_height
            )

        if settings.costView:
            gpu.clearBuffer(self.matCost)

        self.main.lastTime = time

        self.renderView(grid, self.main)

        self.frame += 1

    # 使用独立参数渲染附加相机视图。
    def renderExtraView(self, grid, time, camera, view, parallax):
        delta = clamp(time - view.lastTime, 0, 0.1)
        view.lastTime = time

        # 附加视图临时替换视差，避免其参数污染主视图渲染
        previous = self.settings.frameParallax
        self.settings.frameParallax = parallax

        self.gpu.writeBuffer(
            view.ubo,
            0,
            self.settings.toUbo(
                time,
                delta,
                self.width,
                self.height,
                self.cascadeCount,
                camera,
                view.w,
                view.h,
            ),
        )

        self.settings.frameParallax = previous

        self.renderView(grid, view)

    # 将世界光照投影并执行视图后处理。
    def renderView(self, grid, view):
        linear_sampler, render_settings = self.gpu.linearClamp, self.settings
        view_width, view_height = view.w, view.h
        use_cell_shading = render_settings.b('Enable3D') and not render_settings.voxel
        bindings = Bindings()

        bindings.image(0, self.l0s)
        bindings.image(1, self.l0t)
        bindings.image(2, self.background)
        bindings.sampler(3, linear_sampler, self.fl(0))
        bindings.sampler(4, linear_sampler, self.fl(1))
        bindings.sampler(5, linear_sampler, self.fl(2))
        bindings.sampler(6, linear_sampler, self.fl(3))
        bindings.sampler(7, linear_sampler, self.fl(4))
        bindings.sampler(8, linear_sampler, self.ldir)
        bindings.sampler(9, linear_sampler, grid.medium.read)
        bindings.sampler(10, linear_sampler, self.godrays)
        bindings.ubo(11, view.ubo)
        bindings.image(12, view.hdr)
        bindings.image(13, grid.cells.read)
        bindings.buffer(14, grid.materialsBuf)
        bindings.image(15, self.gaux)
        bindings.sampler(16, linear_sampler, self.occ)
        bindings.sampler(17, linear_sampler, self.side)
        bindings.sampler(18, linear_sampler, self.bgsm)
        bindings.sampler(19, linear_sampler, self.beamTex.read)
        bindings.sampler(20, linear_sampler, self.day.read)
        bindings.image(21, view.cost)
        bindings.buffer(22, self.matCost)
        bindings.sampler(23, linear_sampler, self.fogTex)
        bindings.sampler(24, linear_sampler, self.chA.read)
        bindings.sampler(25, linear_sampler, self.chB.read)
        bindings.image(26, self.emissive)
        bindings.image(27, self.cellShade)

        if use_cell_shading:
            self.dispatch(
                'view_cells',
                bindings,
                Parameters(
                    i0x=self.width,
                    i0y=self.height,
                    i1x=self.width,
                    i1y=self.height,
                ),
                self.width,
                self.height,
            )

        self.dispatch(
            'view3d',
            bindings,
            Parameters(
                i0x=view_width,
                i0y=view_height,
                i0z=self.frame & 0x7FFFFFFF,
                i1x=self.width,
                i1y=self.height,
                i1z=int(use_cell_shading),
            ),
            view_width,
            view_height,
            view_ubo=view.ubo,
        )

        postprocess_source = view.hdr

        if render_settings.b('Enable3D') and render_settings.n('DofStrength') > 0.05:
            # 景深接近零时跳过模糊，减少无明显收益的GPU派发
            dof_bindings = Bindings()

            dof_bindings.sampler(0, linear_sampler, view.hdr)
            dof_bindings.image(1, view.dof)
            self.dispatch(
                'dof',
                dof_bindings,
                Parameters(
                    i0x=view_width,
                    i0y=view_height,
                    f0x=render_settings.n('DofStrength'),
                    f0y=render_settings.n('DofStart'),
                    f0z=max(
                        render_settings.n('DofEnd'), render_settings.n('DofStart') + 1
                    ),
                ),
                view_width,
                view_height,
            )

            postprocess_source = view.dof

        for bloom_level in range(1, 6):
            bloom_width = max(view_width >> bloom_level, 1)
            bloom_height = max(view_height >> bloom_level, 1)
            bloom_down_bindings = Bindings()

            if bloom_level == 1:
                bloom_input = postprocess_source

            else:
                bloom_input = view.bloomDown[bloom_level - 1]

            bloom_down_bindings.sampler(0, linear_sampler, bloom_input)
            bloom_down_bindings.image(1, view.bloomDown[bloom_level])
            self.dispatch(
                'bloom_down',
                bloom_down_bindings,
                Parameters(
                    i0x=bloom_width,
                    i0y=bloom_height,
                    i1x=int(bloom_level == 1),
                    f0x=render_settings.n('BloomThreshold'),
                    f0y=render_settings.n('BloomKnee'),
                ),
                bloom_width,
                bloom_height,
                view_ubo=view.ubo,
            )

        for bloom_level in range(4, 0, -1):
            bloom_width, bloom_height = max(view_width >> bloom_level, 1), max(
                view_height >> bloom_level, 1
            )

            if bloom_level == 4:
                lower_bloom_texture = view.bloomDown[5]

            else:
                lower_bloom_texture = view.bloomUp[bloom_level + 1]

            bloom_up_bindings = Bindings()

            bloom_up_bindings.sampler(0, linear_sampler, lower_bloom_texture)
            bloom_up_bindings.sampler(1, linear_sampler, view.bloomDown[bloom_level])
            bloom_up_bindings.image(2, view.bloomUp[bloom_level])
            self.dispatch(
                'bloom_up',
                bloom_up_bindings,
                Parameters(
                    i0x=bloom_width,
                    i0y=bloom_height,
                    f0x=1,
                    f0y=0.85,
                ),
                bloom_width,
                bloom_height,
                view_ubo=view.ubo,
            )

        exposure_bindings = Bindings()

        exposure_bindings.image(0, postprocess_source)
        exposure_bindings.buffer(1, view.exposure)
        exposure_bindings.ubo(2, view.ubo)

        parameters = Parameters(
            i0x=view_width,
            i0y=view_height,
            i1x=0,
        )

        self.dispatch(
            'exposure', exposure_bindings, parameters, view_width // 2, view_height // 2
        )

        exposure_parameters = parameters.clone()

        exposure_parameters.set('i1x', 1)
        self.dispatch('exposure', exposure_bindings, exposure_parameters, 1, 1)

        tonemap_bindings = Bindings()

        tonemap_bindings.image(0, postprocess_source)
        tonemap_bindings.sampler(1, linear_sampler, view.bloomUp[1])
        tonemap_bindings.buffer(2, view.exposure)
        tonemap_bindings.sampler(3, linear_sampler, self.lut)
        tonemap_bindings.ubo(4, view.ubo)
        tonemap_bindings.image(5, view.output)
        tonemap_bindings.image(6, view.cost)
        self.dispatch(
            'tonemap',
            tonemap_bindings,
            Parameters(
                i0x=view_width,
                i0y=view_height,
                i0z=self.frame & 0x7FFFFFFF,
            ),
            view_width,
            view_height,
            view_ubo=view.ubo,
        )
