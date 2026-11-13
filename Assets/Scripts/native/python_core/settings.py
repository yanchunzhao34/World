"""Day-cycle interpolation, render uniforms and camera coordinates."""

import math

import numpy as np
from _infernux_packages.workshop.runtime.library.dependencies import (
    SimpleNamespace,
    random,
)


# 将数值限制在指定闭区间内。
def clamp(value, minimum, maximum):
    return min(max(value, minimum), maximum)


# 按比例计算两个数值之间的插值。
def lerp(start, end, fraction):
    return start + (end - start) * fraction


# 按参考运算顺序计算二维向量长度。
def vector_length(x, y):
    """Preserve the reference VM's sum-of-squares rounding for engine vectors."""

    return math.sqrt(x * x + y * y)


class RenderSettings:
    # 初始化渲染设置与日照关键帧。
    def __init__(self, values, day_cycle):
        # 颜色参数独立持有，避免多个会话共享可变配置
        self.v = {
            key: list(value) if isinstance(value, list) else value
            for key, value in values.items()
        }
        self.day_cycle = day_cycle
        self.timeOfDay = 10
        self.freezeTime = False
        self.costView = False
        self.frameParallax = [0, 0]

    # 读取指定渲染设置的原始值。
    def n(self, name):
        return self.v[name]

    b = n
    c = n

    # 更新指定渲染设置的当前值。
    def set(self, name, value):
        self.v[name] = value

    # 取得当前体素挤出效果的启用状态。
    @property
    def voxel(self):
        return self.b('Enable3D') and self.b('VoxelExtrude')

    # 取得当前显示模式的有效倾斜角度。
    @property
    def effectiveTilt(self):
        return self.n('Tilt') if self.voxel else 0

    # 取得当前显示模式的有效偏航范围。
    @property
    def effectiveYaw(self):
        return self.n('YawMax') if self.voxel else 0

    # 取得当前显示模式的有效挤出厚度。
    @property
    def effectiveSlab(self):
        return self.n('SlabThickness') if self.voxel else 0

    # 按当前时间插值天空、日光与环境参数。
    @property
    def day(self):
        if not self.b('DayCycleOn'):
            return SimpleNamespace(
                skyTop=self.c('SkyTop')[:3],
                skyHorizon=self.c('SkyHorizon')[:3],
                skyMul=1,
                sunAngle=self.n('SunAngle'),
                sunColor=self.c('SunColor')[:3],
                sunMul=1,
                ambient=self.c('Ambient')[:3],
                ambientMul=1,
                night=0,
            )

        # 时间归一到单日，保证跨午夜与负时间使用同组关键帧
        hour_of_day = (math.fmod(self.timeOfDay, 24) + 24) % 24

        for (start_hour, start_settings), (end_hour, end_settings) in zip(
            self.day_cycle, self.day_cycle[1:]
        ):
            if hour_of_day <= end_hour:
                fraction = clamp(
                    (hour_of_day - start_hour) / max(end_hour - start_hour, 0.0001),
                    0,
                    1,
                )

                # 平滑关键帧端点斜率，避免昼夜变化突然折转
                fraction = fraction * fraction * (3 - 2 * fraction)
                values = {}

                for name in start_settings:
                    if isinstance(start_settings[name], list):
                        values[name] = [
                            lerp(a, b, fraction)
                            for a, b in zip(start_settings[name], end_settings[name])
                        ]

                    else:
                        values[name] = lerp(
                            start_settings[name], end_settings[name], fraction
                        )

                return SimpleNamespace(**values)

        return SimpleNamespace(**self.day_cycle[-1][1])

    # 计算当前昼夜阶段的日光强度。
    @property
    def daylightNow(self):
        return self.n('Daylight') * self.day.sunMul

    # 计算当前日光在世界中的归一化方向。
    def daylightDir(self):
        angle = self.day.sunAngle * math.pi / 180
        x, y = -math.cos(angle), max(math.sin(angle), 0.25)
        length = vector_length(x, y)

        return [x / length, y / length]

    # 按着色器布局打包渲染统一参数。
    def toUbo(
        self, time, delta, width, height, cascade_count, camera, view_width, view_height
    ):
        day = self.day
        get_setting = self.n

        # 字段顺序与WGSL统一，调整参数时需同步维护GPU布局
        rows = []

        # 按颜色、倍率和附加分量组装参数行。
        def color(rgb, multiplier, alpha):
            return [
                rgb[0] * multiplier,
                rgb[1] * multiplier,
                rgb[2] * multiplier,
                alpha,
            ]

        angle = day.sunAngle * math.pi / 180
        ambient = self.c('Ambient')

        rows.extend(
            [
                color(day.skyTop, get_setting('SkyIntensity') * day.skyMul, 0),
                color(day.skyHorizon, get_setting('SkyIntensity') * day.skyMul, 0),
                [
                    math.cos(angle),
                    -math.sin(angle),
                    math.cos(get_setting('SunSize') * math.pi / 180),
                    get_setting('SunIntensity') * day.sunMul,
                ],
                color(day.sunColor, 1, 0),
                [
                    day.ambient[i]
                    * ambient[i]
                    * get_setting('AmbientIntensity')
                    * day.ambientMul
                    for i in range(3)
                ]
                + [get_setting('BackwallLight')],
                [
                    get_setting('Bounce'),
                    get_setting('Temporal'),
                    int(bool(get_setting('BilinearFix'))),
                    get_setting('FluenceGain'),
                ],
                [
                    get_setting('BloomThreshold'),
                    get_setting('BloomKnee'),
                    get_setting('BloomIntensity'),
                    get_setting('GodRays'),
                ],
                [
                    get_setting('MinEv'),
                    get_setting('MaxEv'),
                    get_setting('AdaptUp'),
                    get_setting('AdaptDown'),
                ],
                [
                    get_setting('ExposureComp')
                    - day.night * get_setting('NightDarkness') * 2.2,
                    int(bool(get_setting('AutoExposure'))),
                    get_setting('ManualEv'),
                    delta,
                ],
                [
                    get_setting('SootSigma'),
                    get_setting('SteamSigma'),
                    get_setting('FlameIntensity'),
                    get_setting('ZThickness'),
                ],
                color(self.c('SootColor'), 1, 0),
                color(self.c('SteamColor'), 1, 0),
                [
                    get_setting('HeatDistortion'),
                    get_setting('LiquidSpecular'),
                    get_setting('Saturation'),
                    get_setting('Contrast'),
                ],
                [time, get_setting('LutStrength'), width, height],
                [
                    cascade_count,
                    get_setting('InteriorLight'),
                    get_setting('CrossSectionFill'),
                    int(bool(get_setting('BgSmooth') and get_setting('Enable3D'))),
                ],
                [
                    get_setting('MediumLightExtinction'),
                    min(get_setting('MediumScatter'), 0.9),
                    get_setting('WaterReflection'),
                    get_setting('SurfaceSparkle'),
                ],
                [*camera.center, camera.halfW, camera.halfH],
                [camera.dist, camera.tiltTop, camera.tiltBottom, camera.tiltCurve],
                [
                    camera.yaw,
                    get_setting('FrontRim'),
                    get_setting('TheatreSlope'),
                    self.effectiveSlab,
                ],
                [
                    get_setting('FrontDepth'),
                    get_setting('BackSmooth'),
                    get_setting('BackFade'),
                    get_setting('EdgeRim'),
                ],
                [8, 160, get_setting('BgDepthScale'), get_setting('HazeDensity')],
                color(self.c('HazeColor'), 1, get_setting('FogDepth')),
                [
                    view_width,
                    view_height,
                    get_setting('SideShade'),
                    get_setting('TheatreDepth'),
                ],
                [
                    get_setting('AirDust'),
                    get_setting('TheatreHaze'),
                    get_setting('TheatreLight'),
                    get_setting('DustMotes'),
                ],
            ]
        )

        enabled = get_setting('Enable3D')

        rows.append(
            [
                get_setting('FormLight') if self.voxel else 0,
                get_setting('DropShadow') if enabled else 0,
                get_setting('DropOffset'),
                get_setting('BgDim') if enabled else 1,
            ]
        )

        bevel = enabled and not get_setting('VoxelExtrude')

        rows.append(
            [
                self.frameParallax[0] if bevel else 0,
                self.frameParallax[1] if bevel else 0,
                get_setting('BackRim') if bevel else 0,
                max(get_setting('Bevel'), 0.001) if bevel else 0,
            ]
        )
        rows.append(
            [
                get_setting('WindowShafts') if enabled else 0,
                get_setting('ShaftFall'),
                int(self.costView),
                get_setting('WorldBrightness'),
            ]
        )
        rows.append(
            [
                get_setting('ShadowLift'),
                get_setting('StillWaterMotion'),
                *self.daylightDir(),
            ]
        )
        rows.append(
            [
                day.night,
                self.timeOfDay,
                get_setting('GlossyReflection'),
                get_setting('DirectionalGI'),
            ]
        )

        return np.asarray(rows, dtype='<f4').reshape(116)


class WorldCamera:
    # 初始化相机视图及平滑交互状态。
    def __init__(self):
        self.worldSize = [512, 288]
        self.center = [256, 144]

        self.zoom = 1.875
        self.targetZoom = 1.875
        self.minZoom, self.maxZoom = 1, 12

        self.shake = [0, 0]

        self.tiltTopDeg, self.tiltBottomDeg, self.tiltCurve = 16, 0, 1.2
        self.yawMaxDeg, self.fovYDeg = 3, 24
        self.yaw = 0
        self.userYaw = 0
        self.userYawTarget = 0
        self.maxUserYawDeg = 22
        self.applyYaw = True

        self.screen = [1280, 720]
        self.shakeAmount = 0

        self.zoomAnchorCell = self.zoomAnchorScreen = [0, 0]
        self.zoomAnimating = False

        self.updateView()

    # 让相机视图适应当前世界尺寸。
    def fit(self):
        self.zoom = min(
            self.screen[0] / self.worldSize[0], self.screen[1] / self.worldSize[1]
        )
        self.minZoom = self.zoom * 0.95
        self.targetZoom = self.zoom
        self.zoomAnimating = False
        self.center = [self.worldSize[0] * 0.5, self.worldSize[1] * 0.5]

        self.updateView()

    # 直接设置编排相机的中心与缩放。
    def setView(self, center, zoom):
        self.zoom = min(
            self.screen[0] / self.worldSize[0], self.screen[1] / self.worldSize[1]
        ) * max(zoom, 1)
        self.targetZoom = self.zoom
        self.zoomAnimating = False
        self.center = list(center)

        self.updateView()

    # 将视口像素位置映射到世界格子坐标。
    def screenToCell(self, x, y):
        return [
            self.view.center[0] + (x / self.screen[0] * 2 - 1) * self.view.halfW,
            self.view.center[1] + (y / self.screen[1] * 2 - 1) * self.view.halfH,
        ]

    # 将世界格子位置映射到视口像素坐标。
    def cellToScreen(self, x, y):
        return [
            ((x - self.view.center[0]) / self.view.halfW * 0.5 + 0.5) * self.screen[0],
            ((y - self.view.center[1]) / self.view.halfH * 0.5 + 0.5) * self.screen[1],
        ]

    # 计算世界半径在当前视口中的显示大小。
    def screenRadius(self, x, y, radius):
        start, end = self.cellToScreen(x, y), self.cellToScreen(x + radius, y)

        return vector_length(end[0] - start[0], end[1] - start[1])

    # 累积受限的用户偏航目标。
    def turn(self, value):
        self.userYawTarget = clamp(
            self.userYawTarget + value, -self.maxUserYawDeg, self.maxUserYawDeg
        )

    # 直接同步用户偏航值与目标值。
    def setUserYaw(self, value):
        self.userYaw = self.userYawTarget = value

    # 将用户偏航目标重置到视图中心。
    def recentreYaw(self):
        self.userYawTarget = 0

    # 在既有上限内累积相机震屏强度。
    def addShake(self, value):
        self.shakeAmount = min(self.shakeAmount + value, 6)

    # 根据当前相机状态计算渲染投影参数。
    def updateView(self):
        horizontal = clamp(
            (self.center[0] - self.worldSize[0] * 0.5) / (self.worldSize[0] * 0.5),
            -1,
            1,
        )
        self.yaw = -self.yawMaxDeg * horizontal + self.userYaw if self.applyYaw else 0
        half_height = self.screen[1] * 0.5 / max(self.zoom, 0.01)
        self.view = SimpleNamespace(
            center=[self.center[i] + self.shake[i] for i in range(2)],
            halfW=self.screen[0] * 0.5 / max(self.zoom, 0.01),
            halfH=half_height,
            dist=half_height
            / math.tan(clamp(self.fovYDeg, 1, 120) * math.pi / 180 * 0.5),
            tiltTop=self.tiltTopDeg * math.pi / 180,
            tiltBottom=self.tiltBottomDeg * math.pi / 180,
            tiltCurve=max(self.tiltCurve, 0.05),
            yaw=self.yaw * math.pi / 180,
        )

    # 记录缩放目标及鼠标锚定位置。
    def zoomAt(self, x, y, zoom):
        self.targetZoom = clamp(zoom, self.minZoom, self.maxZoom)
        self.zoomAnchorScreen = [x, y]
        self.zoomAnchorCell = self.screenToCell(x, y)
        self.zoomAnimating = True

    # 按倍率调整当前缩放目标。
    def zoomBy(self, x, y, factor):
        self.zoomAt(
            x, y, (self.targetZoom if self.zoomAnimating else self.zoom) * factor
        )

    # 按当前缩放比例移动相机中心。
    def panBy(self, x, y):
        self.center = [self.center[0] - x / self.zoom, self.center[1] - y / self.zoom]

        self.clampCenter()

    # 将相机中心约束到允许的世界范围。
    def clampCenter(self):
        # 世界小于视口时居中，避免边界约束反向造成相机抖动
        lower_bound = [
            self.screen[i] * 0.5 / self.zoom - 110 / self.zoom for i in range(2)
        ]
        upper_bound = [self.worldSize[i] - lower_bound[i] for i in range(2)]
        clamped_center = []

        for axis_index in range(2):
            if lower_bound[axis_index] > upper_bound[axis_index]:
                axis_center = self.worldSize[axis_index] * 0.5

            else:
                axis_center = clamp(
                    self.center[axis_index],
                    lower_bound[axis_index],
                    upper_bound[axis_index],
                )

            clamped_center.append(axis_center)

        self.center = clamped_center

    # 推进平滑缩放、偏航、移动与震屏。
    def update(self, delta, movement=(0, 0), yaw=0):
        if self.zoomAnimating:
            self.zoom = lerp(self.zoom, self.targetZoom, 1 - math.exp(-18 * delta))

            if abs(self.zoom - self.targetZoom) < 0.001:
                self.zoom, self.zoomAnimating = self.targetZoom, False

            self.updateView()

            # 缩放时补偿中心位移，让鼠标指向的世界位置保持稳定
            current_anchor_cell = self.screenToCell(*self.zoomAnchorScreen)
            self.center = [
                self.center[i] + self.zoomAnchorCell[i] - current_anchor_cell[i]
                for i in range(2)
            ]

            self.clampCenter()

        self.userYawTarget = clamp(
            self.userYawTarget + yaw * 40 * delta,
            -self.maxUserYawDeg,
            self.maxUserYawDeg,
        )
        self.userYaw = lerp(self.userYaw, self.userYawTarget, 1 - math.exp(-8 * delta))

        if movement[0] or movement[1]:
            self.center = [
                self.center[i] + movement[i] * 700 * delta / self.zoom for i in range(2)
            ]

            self.clampCenter()

        self.shakeAmount = max(0, self.shakeAmount - delta * 10)

        if self.shakeAmount > 0.01:
            self.shake = [
                (random.random() * 2 - 1) * self.shakeAmount for _ in range(2)
            ]

        else:
            self.shake = [0, 0]

        self.updateView()
