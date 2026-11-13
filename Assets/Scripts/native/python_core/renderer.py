"""Radiance cascades, view projection and postprocessing, scheduled in Python."""

import math

import numpy as np

from .gpu import Bindings, ComputeShader, DoubleBuffer, Parameters
from .settings import WorldCamera, clamp


def cascade_range(index):
    return 2*(4**index-1)/3, 2*(4**(index+1)-1)/3


class RenderView:
    def __init__(self, gpu, width, height, exposure, uniform):
        self.w, self.h = width, height
        self.exposure, self.ubo, self.lastTime = exposure, uniform, 0
        self.hdr = gpu.createTexture(width, height, 'rgba16float', 'view_hdr')
        self.dof = gpu.createTexture(width, height, 'rgba16float', 'view_dof')
        self.cost = gpu.createTexture(width, height, 'rgba16float', 'cost_view')
        self.output = gpu.createTexture(width, height, 'rgba8unorm', 'final')
        self.bloomDown, self.bloomUp = [None]*6, [None]*5
        for level in range(1, 6):
            self.bloomDown[level] = gpu.createTexture(max(width>>level, 1), max(height>>level, 1), 'rgba16float', 'bloom_d'+str(level))
            if level < 5:
                self.bloomUp[level] = gpu.createTexture(max(width>>level, 1), max(height>>level, 1), 'rgba16float', 'bloom_u'+str(level))
        gpu.clearTexture(self.hdr)

    @classmethod
    def create(cls, gpu, width, height):
        exposure = gpu.createStorageBuffer(16, np.asarray([0, 0, 0, 1], '<f4'), 'exposure_extra')
        uniform = gpu.createUniformBuffer(464, 'render_params_extra')
        return cls(gpu, max(64, width & -8), max(64, height & -8), exposure, uniform)

    def destroy(self, shared=False):
        for texture in [self.hdr, self.dof, self.cost, self.output, *self.bloomDown, *self.bloomUp]:
            if texture is not None:
                texture.destroy()
        # 主视图共享曝光与参数缓冲，视口重建时由渲染器继续持有
        if not shared:
            self.exposure.destroy()
            self.ubo.destroy()


class WorldRenderer:
    OCCLUSION_PASSES = {'bloom_down', 'bloom_up', 'tonemap', 'front_fog', 'view3d'}

    def __init__(self, gpu, width, height, settings, grading_lut, view_width=1536, view_height=864):
        self.gpu, self.width, self.height, self.settings = gpu, width, height, settings
        self.mode = self.debugCascade = 0
        self.spacing, self.frame, self.lastTime = 1, 0, 0
        self.lightHalfRate, self.midHalf = False, True
        self.farFrom, self.fixBelow = 2, 3
        self.retired = []
        self.main = self.upperAvg = self.ldir = self.fluence = self.chA = self.chB = None
        self.cascades, self.flMips = [], []
        diagonal = math.sqrt(width*width+height*height)
        self.cascadeCount = next((count for count in range(3, 8) if cascade_range(count-1)[1] >= diagonal
            and width % (1<<count) == 0 and height % (1<<count) == 0), None)
        if self.cascadeCount is None:
            raise ValueError('World size is not supported by the cascade layout')
        self.debugOutput = self.texture(width, height, 'debug_out', 'rgba8unorm')
        self.background = self.texture(width, height, 'background', 'rgba8uint')
        self.debugPass = ComputeShader(gpu, 'render/debug_view.comp')
        self.albedo = self.texture(width, height, 'albedo')
        self.emissive = self.texture(width, height, 'emissive')
        self.rcsrc = self.texture(width, height, 'rc_src')
        self.gaux = self.texture(width, height, 'gaux')
        self.l0s, self.l0t = self.texture(width, height, 'layer0_s'), self.texture(width, height, 'layer0_t')
        self.mips, self.extMips = [self.rcsrc], [self.texture(width, height, 'rc_ext')]
        for level in range(1, 5):
            self.mips.append(self.texture(width>>level, height>>level, 'rc_mip'+str(level)))
            self.extMips.append(self.texture(width>>level, height>>level, 'rc_ext_mip'+str(level)))
        self.allocLight(1)
        self.godrays = self.texture(width//2, height//2, 'godrays')
        self.exposureBuf = gpu.createStorageBuffer(16, np.asarray([0, 0, 0, 1], '<f4'), 'exposure')
        self.ubo = gpu.createUniformBuffer(464, 'render_params')
        self.lut = gpu.createTexture(32, 32, 'rgba16float', 'grading_lut', 32)
        gpu.writeTexture(self.lut, grading_lut)
        passes = ['gbuffer', 'rc_mips', 'rc_cascade', 'rc_resolve', 'composite', 'bloom_down', 'bloom_up',
            'exposure', 'tonemap', 'godrays', 'downsample', 'view3d', 'occ_field', 'dof', 'subsurface',
            'beam_waves', 'beam_probe', 'light_prep', 'beam_blur', 'window_shafts', 'front_fog',
            'fog_backlight', 'daylight', 'view_cells', 'rc_avg']
        self.p = {name: ComputeShader(gpu, 'render/'+name+'.comp') for name in passes}
        self.occ = self.texture(width, height, 'occ_field')
        self.side = self.texture(width, height, 'side_colour')
        self.bgsm = self.texture(width, height, 'bg_smooth')
        self.sunHit = gpu.createStorageBuffer(640*4, None, 'sun_hits')
        self.lampProbe = gpu.createStorageBuffer(math.ceil(((width+1)>>1)/8)*math.ceil(((height+1)>>1)/8)*16, None, 'lamp_probes')
        self.rcOccBuf = gpu.createStorageBuffer(512, None, 'rc_occupancy')
        self.dayCells = self.texture(width, height, 'day_cells', 'rgba32uint')
        self.beamBuf = gpu.createStorageBuffer(width//2*(height//2)*20, None, 'mirror_beams')
        self.shafts = self.texture(width, height, 'window_shafts')
        self.day = self.pair(width, height, 'daylight')
        self.fogTex = self.texture(width, height, 'front_fog')
        self.backlight = self.texture(width, height, 'fog_backlight')
        self.cellShade = self.texture(width, height*3, 'cell_shade', 'rgba32float')
        self.matCost = gpu.createStorageBuffer(1040, None, 'material_cost')
        self.beamTex = self.pair(width//2, height//2, 'beam')
        self.beamDir = self.pair(width//2, height//2, 'beam_dir')
        self.glossA, self.glossB = self.texture(width, height, 'gloss_a'), self.texture(width, height, 'gloss_b')
        self.sub = self.pair(width, height, 'subsurface')
        for pair in (self.fluence, self.day, self.beamTex, self.beamDir, self.sub, self.chA, self.chB):
            gpu.clearTexture(pair.read)
            gpu.clearTexture(pair.write)
        gpu.clearTexture(self.ldir)
        self.setViewSize(view_width, view_height)

    def texture(self, width, height, label, format='rgba16float'):
        return self.gpu.createTexture(max(int(width), 1), max(int(height), 1), format, label)

    def pair(self, width, height, label):
        return DoubleBuffer(self.texture(width, height, label+'_a'), self.texture(width, height, label+'_b'))

    @property
    def output(self):
        return self.main.output

    @property
    def viewW(self):
        return self.main.w if self.main else 0

    @property
    def viewH(self):
        return self.main.h if self.main else 0

    @property
    def fluenceTex(self):
        return self.fluence.read

    @property
    def daylightTex(self):
        return self.day.read

    @property
    def lightSpacing(self):
        return self.spacing

    def setLightSpacing(self, spacing):
        if spacing != self.spacing:
            self.allocLight(spacing)

    def allocLight(self, spacing):
        retired = [*self.cascades, self.upperAvg, *self.flMips[1:], self.ldir]
        for pair in (self.fluence, self.chA, self.chB):
            if pair:
                retired.extend((pair.read, pair.write))
        retired = [texture for texture in retired if texture is not None]
        if retired:
            # 延迟释放旧光场，避免在途帧引用失效的纹理
            self.retired.append((retired, self.frame+3))
        self.spacing = spacing
        width, height = self.width//spacing, self.height//spacing
        self.cascades = [self.texture(width*4, height*4, 'cascade'+str(index)) for index in range(self.cascadeCount)]
        self.upperAvg = self.texture(width*2, height*2, 'cascade_upper_avg', 'rgba32float')
        self.fluence = self.pair(width, height, 'fluence')
        self.flMips = [self.fluence.read] + [self.texture(width>>level, height>>level, 'fluence_mip'+str(level)) for level in range(1, 5)]
        self.ldir = self.texture(width, height, 'light_dir')
        self.chA, self.chB = self.pair(width, height, 'ch_a'), self.pair(width, height, 'ch_b')
        for pair in (self.fluence, self.chA, self.chB):
            self.gpu.clearTexture(pair.read)
            self.gpu.clearTexture(pair.write)
        self.gpu.clearTexture(self.ldir)

    def fl(self, level):
        return self.flMips[max(level-(self.spacing>>1), 0)]

    def uploadBackground(self, data):
        self.gpu.writeTexture(self.background, data)

    def setViewSize(self, width, height):
        width, height = max(64, int(width)&-8), max(64, int(height)&-8)
        if self.main and width == self.main.w and height == self.main.h:
            return False
        if self.main:
            self.main.destroy(True)
        self.main = RenderView(self.gpu, width, height, self.exposureBuf, self.ubo)
        return True

    def defaultCamera(self):
        camera = WorldCamera()
        camera.center, camera.screen = [self.width/2, self.height/2], [self.viewW, self.viewH]
        camera.zoom = min(self.viewW/self.width, self.viewH/self.height)
        camera.tiltTopDeg = self.settings.effectiveTilt
        camera.tiltBottomDeg = self.settings.n('TiltBottom') if self.settings.b('Enable3D') else 0
        camera.tiltCurve, camera.fovYDeg = self.settings.n('TiltCurve'), self.settings.n('FovY')
        camera.updateView()
        return camera.view

    def dispatch(self, name, bindings, parameters, width, height, *, view_ubo=None):
        if self.gpu.host.lighting_corrections and name in self.OCCLUSION_PASSES:
            # 后处理也需读取材质遮挡，避免模糊光晕穿过实体墙面
            bindings.image(30, self.extMips[0]).image(31, self.emissive)
            if name not in ('front_fog', 'view3d'):
                bindings.ubo(32, view_ubo or self.ubo)
        self.p[name].dispatch(bindings, parameters, width, height)

    def render(self, grid, time, camera=None):
        self.renderFinal(grid, time, camera or self.defaultCamera())
        if self.mode == 0:
            return
        texture, channel, gain = grid.fluidVel.read, 0, 1
        if self.mode in (1, 2, 3, 4, 5, 10):
            mode = {1:0, 2:1, 3:2, 4:3, 5:4, 10:6}[self.mode]
            if self.mode == 4:
                gain = 1.5
            if self.mode == 5:
                texture = grid.medium.read
        else:
            mode = 5
            choices = {6:self.fluence.read, 7:self.cascades[clamp(self.debugCascade, 0, self.cascadeCount-1)],
                       8:self.rcsrc, 9:self.rcsrc}
            texture = choices.get(self.mode, self.l0s)
            if self.mode == 9:
                channel, gain = 1, .5
        self.debugPass.dispatch(Bindings().image(0, grid.cells.read).buffer(1, grid.materialsBuf)
            .image(2, self.debugOutput).sampler(3, self.gpu.linearClamp, texture),
            Parameters(i0x=self.width, i0y=self.height, i1x=mode, i1y=channel, f0x=gain), self.width, self.height)

    def renderFinal(self, grid, time, camera):
        gpu, settings = self.gpu, self.settings
        width, height = self.width, self.height
        delta = clamp(time-self.lastTime, 0, .1)
        self.lastTime = time
        while self.retired and self.retired[0][1] <= self.frame:
            for texture in self.retired.pop(0)[0]:
                texture.destroy()
        gpu.writeBuffer(self.ubo, 0, settings.toUbo(time, delta, width, height, self.cascadeCount, camera, self.viewW, self.viewH))
        sampler = gpu.linearClamp
        mirror, lamp = settings.n('MirrorBeams'), settings.n('LampBeams')
        # 交错更新远场与介质，利用历史光照分摊每帧计算开销
        even = not self.frame & 1
        light_update = not self.lightHalfRate or even
        medium_update = not (self.lightHalfRate or self.midHalf) or not even
        far_update = self.lightHalfRate or even
        if medium_update:
            gpu.clearBuffer(self.beamBuf)
            direction = settings.daylightDir()
            columns, rows = math.ceil(((width+1)>>1)/8), math.ceil(((height+1)>>1)/8)
            beam_steps = math.ceil((math.floor(2*(math.sqrt(width*width+height*height)*.5+2))+1)/32)
            parameters = Parameters(i0x=width, i0y=height, i0z=beam_steps, i1x=columns, i1y=rows,
                i1z=int(mirror>0), i1w=int(lamp>0), f0x=mirror, f0y=settings.n('MirrorBeamRange'),
                f1x=direction[0], f1y=direction[1], f1z=lamp)
            bindings = (Bindings().image(0, grid.cells.read).buffer(1, grid.materialsBuf).image(2, self.albedo)
                .image(3, self.emissive).image(4, self.gaux).sampler(5, sampler, self.fluence.read)
                .sampler(6, sampler, self.ldir).buffer(7, self.beamBuf).sampler(8, sampler, self.day.read)
                .sampler(9, sampler, self.beamTex.read).sampler(10, sampler, grid.medium.read)
                .buffer(11, self.sunHit).buffer(12, self.lampProbe))
            if mirror > 0:
                gpu.clearBuffer(self.sunHit)
            probes = (math.ceil(640*beam_steps/256) if mirror>0 else 0) + (columns*rows if lamp>0 else 0)
            if probes > 0:
                self.dispatch('beam_probe', bindings, parameters, probes*256, 1)
            waves = (80+math.ceil(width/8)*math.ceil(height/8) if mirror>0 else 0) + (columns*rows*8 if lamp>0 else 0)
            if waves > 0:
                self.dispatch('beam_waves', bindings, parameters, waves*8, 8)
            self.dispatch('beam_blur', Bindings().buffer(0, self.beamBuf).image(1, self.beamTex.read)
                .image(2, self.beamTex.write).image(3, self.beamDir.write).image(4, self.beamDir.read),
                Parameters(i0x=width//2, i0y=height//2, f0x=.07), width//2, height//2)
            self.beamTex.swap()
            self.beamDir.swap()
        self.dispatch('gbuffer', Bindings().image(0, grid.cells.read).buffer(1, grid.materialsBuf)
            .sampler(2, sampler, grid.medium.read).sampler(3, sampler, self.fluence.read).ubo(4, self.ubo)
            .image(5, self.albedo).image(6, self.emissive).image(7, self.rcsrc).image(8, self.gaux)
            .image(9, self.background).image(10, self.extMips[0]).sampler(11, sampler, self.beamTex.read)
            .sampler(12, sampler, self.day.read).sampler(13, sampler, self.ldir).image(14, self.glossA),
            Parameters(i0x=width, i0y=height, i0z=self.frame&0x7fffffff), width, height)
        if light_update:
            for level in range(1, 5):
                self.dispatch('rc_mips', Bindings().image(0, self.mips[level-1]).image(1, self.mips[level])
                    .image(2, self.extMips[level-1]).image(3, self.extMips[level]),
                    Parameters(i0x=width>>level, i0y=height>>level), width>>level, height>>level)
        gpu.clearBuffer(self.rcOccBuf)
        self.dispatch('light_prep', Bindings().image(0, self.glossA).buffer(1, self.rcOccBuf)
            .image(2, self.albedo).image(3, self.emissive).image(4, self.background)
            .image(5, grid.cells.read).image(6, self.dayCells),
            Parameters(i0x=width, i0y=height, i0z=width//8, i0w=height//8), width, height)
        if light_update:
            # 从远到近求解级联，让近层可复用远层的入射光
            for cascade in range(self.cascadeCount-1, -1, -1):
                if (cascade >= self.farFrom and not far_update or
                    not self.lightHalfRate and cascade > self.farFrom and self.frame&3 != (0 if cascade == self.farFrom+1 else 2)):
                    continue
                level = clamp(cascade-1, 0, 4)
                near, far = cascade_range(cascade)
                parameters = Parameters(i0x=width, i0y=height, i0z=cascade, i0w=self.cascadeCount,
                    i1x=self.spacing<<cascade, i1y=4<<cascade,
                    i1z=int(settings.b('BilinearFix') and cascade<self.fixBelow), i1w=level,
                    f0x=near, f0y=far, f0z=max(1, 1<<level))
                packed_width, packed_height = width//self.spacing*4, height//self.spacing*4
                if cascade < self.cascadeCount-1:
                    self.dispatch('rc_avg', Bindings().sampler(0, gpu.nearestClamp, self.cascades[cascade+1]).image(1, self.upperAvg),
                        Parameters(i0x=packed_width//2, i0y=packed_height//2, i1y=4<<cascade), packed_width//2, packed_height//2)
                self.dispatch('rc_cascade', Bindings().sampler(0, sampler, self.mips[level]).image(1, self.upperAvg)
                    .image(2, self.cascades[cascade]).ubo(3, self.ubo).sampler(4, sampler, self.extMips[level])
                    .sampler(5, gpu.nearestClamp, self.glossA).buffer(6, self.rcOccBuf), parameters, packed_width, packed_height)
            light_width, light_height = width//self.spacing, height//self.spacing
            self.dispatch('rc_resolve', Bindings().image(0, self.cascades[0]).image(1, self.fluence.read)
                .image(2, self.fluence.write).image(3, self.ldir).ubo(4, self.ubo).image(5, self.chA.read)
                .image(6, self.chB.read).image(7, self.chA.write).image(8, self.chB.write),
                Parameters(i0x=light_width, i0y=light_height, i1x=4), light_width, light_height)
            self.fluence.swap()
            self.chA.swap()
            self.chB.swap()
            self.flMips[0] = self.fluence.read
            for level in range(1, 5):
                mip_width, mip_height = max(light_width>>level, 1), max(light_height>>level, 1)
                self.dispatch('downsample', Bindings().image(0, self.flMips[level-1]).image(1, self.flMips[level]),
                    Parameters(i0x=mip_width, i0y=mip_height), mip_width, mip_height)
        parameters = Parameters(i0x=width, i0y=height)
        if medium_update:
            for _ in range(6):
                self.dispatch('subsurface', Bindings().image(0, grid.cells.read).buffer(1, grid.materialsBuf)
                    .image(2, self.albedo).image(3, self.emissive).image(4, self.gaux)
                    .sampler(5, sampler, self.fluence.read).image(6, self.sub.read).image(7, self.sub.write), parameters, width, height)
                self.sub.swap()
            direction = settings.daylightDir()
            self.dispatch('daylight', Bindings().sampler(3, sampler, grid.medium.read).image(4, self.day.write)
                .ubo(5, self.ubo).buffer(7, grid.materialsBuf).image(8, self.day.read).image(10, self.dayCells),
                Parameters(i0x=width, i0y=height, f0x=direction[0], f0y=direction[1], f0z=settings.daylightNow,
                    f0w=settings.n('DaylightRange')), width, height)
            self.day.swap()
        self.dispatch('composite', Bindings().image(0, self.albedo).image(1, self.emissive).image(2, self.gaux)
            .sampler(3, sampler, self.fluence.read).sampler(4, sampler, self.ldir).sampler(5, sampler, grid.medium.read)
            .image(6, grid.cells.read).buffer(7, grid.materialsBuf).ubo(8, self.ubo).image(9, self.l0s)
            .image(10, self.l0t).image(11, self.sub.read).sampler(12, sampler, self.day.read)
            .sampler(13, sampler, self.beamTex.read).sampler(14, sampler, self.beamDir.read)
            .sampler(15, sampler, self.chA.read).sampler(16, sampler, self.chB.read), parameters, width, height)
        self.dispatch('godrays', Bindings().sampler(0, sampler, self.rcsrc).image(1, self.background)
            .sampler(2, sampler, grid.medium.read).image(3, self.godrays).ubo(4, self.ubo),
            Parameters(i0x=width//2, i0y=height//2, i1x=width, i1y=height), width//2, height//2)
        if settings.b('Enable3D') and (not self.lightHalfRate or even):
            self.dispatch('occ_field', Bindings().image(0, self.l0s).image(1, self.occ).image(2, self.side)
                .image(3, self.background).image(4, self.bgsm), parameters, width, height)
        if settings.b('Enable3D') and not settings.b('VoxelExtrude') and (not self.lightHalfRate or not even):
            # 雾光使用未跨墙模糊的光场，避免积分带入墙后亮度
            backlight_levels = (self.fluence.read, self.fluence.read) if gpu.host.lighting_corrections else (self.fl(2), self.fl(3))
            self.dispatch('fog_backlight', Bindings().image(0, self.l0s).image(1, self.l0t)
                .sampler(2, sampler, backlight_levels[0]).sampler(3, sampler, backlight_levels[1])
                .sampler(4, sampler, self.day.read).image(5, self.backlight), parameters, width, height)
            self.dispatch('front_fog', Bindings().image(0, self.l0s).image(1, self.l0t).image(2, self.background)
                .sampler(3, sampler, self.fl(2)).sampler(4, sampler, self.fl(3)).image(5, self.fogTex)
                .ubo(6, self.ubo).sampler(7, sampler, self.day.read).image(8, self.backlight), parameters, width, height)
        if settings.costView:
            gpu.clearBuffer(self.matCost)
        self.main.lastTime = time
        self.renderView(grid, self.main)
        self.frame += 1

    def renderExtraView(self, grid, time, camera, view, parallax):
        delta = clamp(time-view.lastTime, 0, .1)
        view.lastTime = time
        # 附加视图临时替换视差，避免其参数污染主视图渲染
        previous = self.settings.frameParallax
        self.settings.frameParallax = parallax
        self.gpu.writeBuffer(view.ubo, 0, self.settings.toUbo(time, delta, self.width, self.height,
            self.cascadeCount, camera, view.w, view.h))
        self.settings.frameParallax = previous
        self.renderView(grid, view)

    def renderView(self, grid, view):
        sampler, settings = self.gpu.linearClamp, self.settings
        width, height = view.w, view.h
        cells_enabled = settings.b('Enable3D') and not settings.voxel
        bindings = (Bindings().image(0, self.l0s).image(1, self.l0t).image(2, self.background)
            .sampler(3, sampler, self.fl(0)).sampler(4, sampler, self.fl(1)).sampler(5, sampler, self.fl(2))
            .sampler(6, sampler, self.fl(3)).sampler(7, sampler, self.fl(4)).sampler(8, sampler, self.ldir)
            .sampler(9, sampler, grid.medium.read).sampler(10, sampler, self.godrays).ubo(11, view.ubo)
            .image(12, view.hdr).image(13, grid.cells.read).buffer(14, grid.materialsBuf).image(15, self.gaux)
            .sampler(16, sampler, self.occ).sampler(17, sampler, self.side).sampler(18, sampler, self.bgsm)
            .sampler(19, sampler, self.beamTex.read).sampler(20, sampler, self.day.read).image(21, view.cost)
            .buffer(22, self.matCost).sampler(23, sampler, self.fogTex).sampler(24, sampler, self.chA.read)
            .sampler(25, sampler, self.chB.read).image(26, self.emissive).image(27, self.cellShade))
        if cells_enabled:
            self.dispatch('view_cells', bindings, Parameters(i0x=self.width, i0y=self.height, i1x=self.width, i1y=self.height), self.width, self.height)
        self.dispatch('view3d', bindings, Parameters(i0x=width, i0y=height, i0z=self.frame&0x7fffffff,
            i1x=self.width, i1y=self.height, i1z=int(cells_enabled)), width, height, view_ubo=view.ubo)
        source = view.hdr
        if settings.b('Enable3D') and settings.n('DofStrength') > .05:
            # 景深接近零时跳过模糊，减少无明显收益的GPU派发
            self.dispatch('dof', Bindings().sampler(0, sampler, view.hdr).image(1, view.dof),
                Parameters(i0x=width, i0y=height, f0x=settings.n('DofStrength'), f0y=settings.n('DofStart'),
                    f0z=max(settings.n('DofEnd'), settings.n('DofStart')+1)), width, height)
            source = view.dof
        for level in range(1, 6):
            mip_width, mip_height = max(width>>level, 1), max(height>>level, 1)
            self.dispatch('bloom_down', Bindings().sampler(0, sampler, source if level == 1 else view.bloomDown[level-1])
                .image(1, view.bloomDown[level]), Parameters(i0x=mip_width, i0y=mip_height,
                    i1x=int(level == 1), f0x=settings.n('BloomThreshold'), f0y=settings.n('BloomKnee')),
                mip_width, mip_height, view_ubo=view.ubo)
        for level in range(4, 0, -1):
            mip_width, mip_height = max(width>>level, 1), max(height>>level, 1)
            low = view.bloomDown[5] if level == 4 else view.bloomUp[level+1]
            self.dispatch('bloom_up', Bindings().sampler(0, sampler, low).sampler(1, sampler, view.bloomDown[level])
                .image(2, view.bloomUp[level]), Parameters(i0x=mip_width, i0y=mip_height, f0x=1, f0y=.85),
                mip_width, mip_height, view_ubo=view.ubo)
        exposure_bindings = Bindings().image(0, source).buffer(1, view.exposure).ubo(2, view.ubo)
        parameters = Parameters(i0x=width, i0y=height, i1x=0)
        self.dispatch('exposure', exposure_bindings, parameters, width//2, height//2)
        self.dispatch('exposure', exposure_bindings, parameters.clone().set('i1x', 1), 1, 1)
        self.dispatch('tonemap', Bindings().image(0, source).sampler(1, sampler, view.bloomUp[1])
            .buffer(2, view.exposure).sampler(3, sampler, self.lut).ubo(4, view.ubo)
            .image(5, view.output).image(6, view.cost), Parameters(i0x=width, i0y=height, i0z=self.frame&0x7fffffff),
            width, height, view_ubo=view.ubo)
