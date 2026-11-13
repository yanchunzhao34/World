"""Day-cycle interpolation, render uniforms and camera coordinates."""

import math

import numpy as np
from _infernux_packages.workshop.runtime.library.dependencies import SimpleNamespace, random


def clamp(value, minimum, maximum):
    return min(max(value, minimum), maximum)


def lerp(start, end, fraction):
    return start + (end - start) * fraction


def vector_length(x, y):
    """Preserve the reference VM's sum-of-squares rounding for engine vectors."""
    return math.sqrt(x*x + y*y)


class RenderSettings:
    def __init__(self, values, day_cycle):
        # 颜色参数独立持有，避免多个会话共享可变配置
        self.v = {key: list(value) if isinstance(value, list) else value for key, value in values.items()}
        self.day_cycle = day_cycle
        self.timeOfDay = 10
        self.freezeTime = self.costView = False
        self.frameParallax = [0, 0]

    def n(self, name):
        return self.v[name]

    b = n
    c = n

    def set(self, name, value):
        self.v[name] = value

    @property
    def voxel(self):
        return self.b('Enable3D') and self.b('VoxelExtrude')

    @property
    def effectiveTilt(self):
        return self.n('Tilt') if self.voxel else 0

    @property
    def effectiveYaw(self):
        return self.n('YawMax') if self.voxel else 0

    @property
    def effectiveSlab(self):
        return self.n('SlabThickness') if self.voxel else 0

    @property
    def day(self):
        if not self.b('DayCycleOn'):
            return SimpleNamespace(skyTop=self.c('SkyTop')[:3], skyHorizon=self.c('SkyHorizon')[:3],
                skyMul=1, sunAngle=self.n('SunAngle'), sunColor=self.c('SunColor')[:3], sunMul=1,
                ambient=self.c('Ambient')[:3], ambientMul=1, night=0)
        # 时间归一到单日，保证跨午夜与负时间使用同组关键帧
        hour = (math.fmod(self.timeOfDay, 24) + 24) % 24
        for (start, first), (end, second) in zip(self.day_cycle, self.day_cycle[1:]):
            if hour <= end:
                fraction = clamp((hour - start) / max(end-start, .0001), 0, 1)
                # 平滑关键帧端点斜率，避免昼夜变化突然折转
                fraction = fraction * fraction * (3 - 2 * fraction)
                values = {}
                for name in first:
                    if isinstance(first[name], list):
                        values[name] = [lerp(a, b, fraction) for a, b in zip(first[name], second[name])]
                    else:
                        values[name] = lerp(first[name], second[name], fraction)
                return SimpleNamespace(**values)
        return SimpleNamespace(**self.day_cycle[-1][1])

    @property
    def daylightNow(self):
        return self.n('Daylight') * self.day.sunMul

    def daylightDir(self):
        angle = self.day.sunAngle * math.pi / 180
        x, y = -math.cos(angle), max(math.sin(angle), .25)
        length = vector_length(x, y)
        return [x/length, y/length]

    def toUbo(self, time, delta, width, height, cascade_count, camera, view_width, view_height):
        day = self.day
        value = self.n
        # 字段顺序与WGSL统一，调整参数时需同步维护GPU布局
        rows = []

        def color(rgb, multiplier, alpha):
            return [rgb[0]*multiplier, rgb[1]*multiplier, rgb[2]*multiplier, alpha]

        angle = day.sunAngle * math.pi / 180
        ambient = self.c('Ambient')
        rows.extend([
            color(day.skyTop, value('SkyIntensity')*day.skyMul, 0),
            color(day.skyHorizon, value('SkyIntensity')*day.skyMul, 0),
            [math.cos(angle), -math.sin(angle), math.cos(value('SunSize')*math.pi/180), value('SunIntensity')*day.sunMul],
            color(day.sunColor, 1, 0),
            [day.ambient[i]*ambient[i]*value('AmbientIntensity')*day.ambientMul for i in range(3)] + [value('BackwallLight')],
            [value('Bounce'), value('Temporal'), int(bool(value('BilinearFix'))), value('FluenceGain')],
            [value('BloomThreshold'), value('BloomKnee'), value('BloomIntensity'), value('GodRays')],
            [value('MinEv'), value('MaxEv'), value('AdaptUp'), value('AdaptDown')],
            [value('ExposureComp')-day.night*value('NightDarkness')*2.2, int(bool(value('AutoExposure'))), value('ManualEv'), delta],
            [value('SootSigma'), value('SteamSigma'), value('FlameIntensity'), value('ZThickness')],
            color(self.c('SootColor'), 1, 0), color(self.c('SteamColor'), 1, 0),
            [value('HeatDistortion'), value('LiquidSpecular'), value('Saturation'), value('Contrast')],
            [time, value('LutStrength'), width, height],
            [cascade_count, value('InteriorLight'), value('CrossSectionFill'), int(bool(value('BgSmooth') and value('Enable3D')))],
            [value('MediumLightExtinction'), min(value('MediumScatter'), .9), value('WaterReflection'), value('SurfaceSparkle')],
            [*camera.center, camera.halfW, camera.halfH],
            [camera.dist, camera.tiltTop, camera.tiltBottom, camera.tiltCurve],
            [camera.yaw, value('FrontRim'), value('TheatreSlope'), self.effectiveSlab],
            [value('FrontDepth'), value('BackSmooth'), value('BackFade'), value('EdgeRim')],
            [8, 160, value('BgDepthScale'), value('HazeDensity')],
            color(self.c('HazeColor'), 1, value('FogDepth')),
            [view_width, view_height, value('SideShade'), value('TheatreDepth')],
            [value('AirDust'), value('TheatreHaze'), value('TheatreLight'), value('DustMotes')],
        ])
        enabled = value('Enable3D')
        rows.append([value('FormLight') if self.voxel else 0, value('DropShadow') if enabled else 0,
                     value('DropOffset'), value('BgDim') if enabled else 1])
        bevel = enabled and not value('VoxelExtrude')
        rows.append([self.frameParallax[0] if bevel else 0, self.frameParallax[1] if bevel else 0,
                     value('BackRim') if bevel else 0, max(value('Bevel'), .001) if bevel else 0])
        rows.append([value('WindowShafts') if enabled else 0, value('ShaftFall'), int(self.costView), value('WorldBrightness')])
        rows.append([value('ShadowLift'), value('StillWaterMotion'), *self.daylightDir()])
        rows.append([day.night, self.timeOfDay, value('GlossyReflection'), value('DirectionalGI')])
        return np.asarray(rows, dtype='<f4').reshape(116)


class WorldCamera:
    def __init__(self):
        self.worldSize = [512, 288]
        self.center = [256, 144]
        self.zoom = self.targetZoom = 1.875
        self.minZoom, self.maxZoom = 1, 12
        self.shake = [0, 0]
        self.tiltTopDeg, self.tiltBottomDeg, self.tiltCurve = 16, 0, 1.2
        self.yawMaxDeg, self.fovYDeg = 3, 24
        self.yaw = self.userYaw = self.userYawTarget = 0
        self.maxUserYawDeg = 22
        self.applyYaw = True
        self.screen = [1280, 720]
        self.shakeAmount = 0
        self.zoomAnchorCell = self.zoomAnchorScreen = [0, 0]
        self.zoomAnimating = False
        self.updateView()

    def fit(self):
        self.zoom = min(self.screen[0]/self.worldSize[0], self.screen[1]/self.worldSize[1])
        self.minZoom = self.zoom*.95
        self.targetZoom = self.zoom
        self.zoomAnimating = False
        self.center = [self.worldSize[0]*.5, self.worldSize[1]*.5]
        self.updateView()

    def setView(self, center, zoom):
        self.zoom = min(self.screen[0]/self.worldSize[0], self.screen[1]/self.worldSize[1])*max(zoom, 1)
        self.targetZoom = self.zoom
        self.zoomAnimating = False
        self.center = list(center)
        self.updateView()

    def screenToCell(self, x, y):
        return [self.view.center[0]+(x/self.screen[0]*2-1)*self.view.halfW,
                self.view.center[1]+(y/self.screen[1]*2-1)*self.view.halfH]

    def cellToScreen(self, x, y):
        return [((x-self.view.center[0])/self.view.halfW*.5+.5)*self.screen[0],
                ((y-self.view.center[1])/self.view.halfH*.5+.5)*self.screen[1]]

    def screenRadius(self, x, y, radius):
        start, end = self.cellToScreen(x, y), self.cellToScreen(x+radius, y)
        return vector_length(end[0]-start[0], end[1]-start[1])

    def turn(self, value):
        self.userYawTarget = clamp(self.userYawTarget+value, -self.maxUserYawDeg, self.maxUserYawDeg)

    def setUserYaw(self, value):
        self.userYaw = self.userYawTarget = value

    def recentreYaw(self):
        self.userYawTarget = 0

    def addShake(self, value):
        self.shakeAmount = min(self.shakeAmount+value, 6)

    def updateView(self):
        horizontal = clamp((self.center[0]-self.worldSize[0]*.5)/(self.worldSize[0]*.5), -1, 1)
        self.yaw = -self.yawMaxDeg*horizontal+self.userYaw if self.applyYaw else 0
        half_height = self.screen[1]*.5/max(self.zoom, .01)
        self.view = SimpleNamespace(center=[self.center[i]+self.shake[i] for i in range(2)],
            halfW=self.screen[0]*.5/max(self.zoom, .01), halfH=half_height,
            dist=half_height/math.tan(clamp(self.fovYDeg, 1, 120)*math.pi/180*.5),
            tiltTop=self.tiltTopDeg*math.pi/180, tiltBottom=self.tiltBottomDeg*math.pi/180,
            tiltCurve=max(self.tiltCurve, .05), yaw=self.yaw*math.pi/180)

    def zoomAt(self, x, y, zoom):
        self.targetZoom = clamp(zoom, self.minZoom, self.maxZoom)
        self.zoomAnchorScreen = [x, y]
        self.zoomAnchorCell = self.screenToCell(x, y)
        self.zoomAnimating = True

    def zoomBy(self, x, y, factor):
        self.zoomAt(x, y, (self.targetZoom if self.zoomAnimating else self.zoom)*factor)

    def panBy(self, x, y):
        self.center = [self.center[0]-x/self.zoom, self.center[1]-y/self.zoom]
        self.clampCenter()

    def clampCenter(self):
        # 世界小于视口时居中，避免边界约束反向造成相机抖动
        lower = [self.screen[i]*.5/self.zoom-110/self.zoom for i in range(2)]
        upper = [self.worldSize[i]-lower[i] for i in range(2)]
        self.center = [self.worldSize[i]*.5 if lower[i]>upper[i] else clamp(self.center[i], lower[i], upper[i]) for i in range(2)]

    def update(self, delta, movement=(0, 0), yaw=0):
        if self.zoomAnimating:
            self.zoom = lerp(self.zoom, self.targetZoom, 1-math.exp(-18*delta))
            if abs(self.zoom-self.targetZoom)<.001:
                self.zoom, self.zoomAnimating = self.targetZoom, False
            self.updateView()
            # 缩放时补偿中心位移，让鼠标指向的世界位置保持稳定
            anchor = self.screenToCell(*self.zoomAnchorScreen)
            self.center = [self.center[i]+self.zoomAnchorCell[i]-anchor[i] for i in range(2)]
            self.clampCenter()
        self.userYawTarget = clamp(self.userYawTarget+yaw*40*delta, -self.maxUserYawDeg, self.maxUserYawDeg)
        self.userYaw = lerp(self.userYaw, self.userYawTarget, 1-math.exp(-8*delta))
        if movement[0] or movement[1]:
            self.center = [self.center[i]+movement[i]*700*delta/self.zoom for i in range(2)]
            self.clampCenter()
        self.shakeAmount = max(0, self.shakeAmount-delta*10)
        self.shake = [(random.random()*2-1)*self.shakeAmount for _ in range(2)] if self.shakeAmount>.01 else [0, 0]
        self.updateView()
