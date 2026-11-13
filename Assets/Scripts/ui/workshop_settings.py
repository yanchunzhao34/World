"""原设置键、范围及调试视图。界面通过操作协议更新后台。"""

from .workshop_style import DIM

SWITCHES = {
    "Enable3D": "立体光照",
    "VoxelExtrude": "体素挤出",
    "DayCycleOn": "昼夜循环",
    "AutoExposure": "自动曝光",
    "BilinearFix": "光照插值修正",
    "BgSmooth": "背景平滑",
}
KNOBS = {
    "WorldBrightness": ("画面亮度", 0.1, 3, 0.05),
    "BloomIntensity": ("泛光", 0, 2, 0.02),
    "Daylight": ("日光", 0, 4, 0.05),
    "MirrorBeams": ("镜面光束", 0, 2, 0.05),
    "LampBeams": ("灯光光束", 0, 2, 0.05),
    "HeatDistortion": ("热扭曲", 0, 3, 0.05),
    "Grain": ("颗粒", 0, 0.1, 0.005),
    "ViewHeight": ("内部渲染高度", 288, 1728, 8),
}
DEBUG = [
    "最终画面",
    "平面颜色",
    "材料 ID",
    "温度",
    "流体速度",
    "烟雾",
    "辐照度",
    "级联",
    "自发光",
    "消光",
    "闪光",
]


class WorkshopSettings:
    # 初始化设置面板与滚动状态。
    def __init__(self, app):
        self.app, self.scroll = app, 0

    # 绘制设置面板与滚动并处理交互。
    def render(self, c, rect):
        canvas = c
        app, (x, y, width, height) = self.app, rect
        content = 48 + len(SWITCHES) * 38 + len(KNOBS) * 44 + 90
        self.scroll = min(max(0, content - height), max(0, self.scroll))

        if canvas.hit(rect):
            self.scroll = min(
                max(0, content - height),
                max(0, self.scroll - canvas.ctx.get_mouse_wheel_delta() * 44),
            )

        canvas.clip(rect)

        cy = y - self.scroll

        canvas.text((x, cy, 120, 34), "音量", 13)
        canvas.slider(
            (x + 140, cy, width - 200, 34),
            app.sound.volume,
            0,
            1,
            lambda value: setattr(app.sound, "volume", value),
            "volume",
        )

        cy += 48

        for key, label in SWITCHES.items():
            value = bool(app.settings[key])

            # 控件固定自身键名与值，避免点击后修改其他画面设置
            canvas.button(
                (x, cy, width, 32),
                ("☑ " if value else "☐ ") + label,
                lambda key=key, value=value: app.set_setting(key, not value),
                fill="ffffff00",
                identifier="setting-" + key,
            )

            cy += 38

        for key, (label, minimum, maximum, step) in KNOBS.items():
            value = float(app.settings[key])

            canvas.text((x, cy, 140, 36), label, 13)

            # 滑动值对齐步长，保证滑块与加减按钮的调节粒度一致
            canvas.slider(
                (x + 150, cy + 4, max(40, width - 320), 30),
                value,
                minimum,
                maximum,
                lambda value, key=key, step=step: app.set_setting(
                    key, round(value / step) * step
                ),
                "slider-" + key,
            )
            canvas.button(
                (x + width - 152, cy + 4, 28, 28),
                "−",
                lambda key=key, value=value, step=step, minimum=minimum: app.set_setting(
                    key, max(minimum, value - step)
                ),
            )
            canvas.text((x + width - 120, cy, 80, 36), f"{value:g}", 13, align=0.5)
            canvas.button(
                (x + width - 36, cy + 4, 28, 28),
                "+",
                lambda key=key, value=value, step=step, maximum=maximum: app.set_setting(
                    key, min(maximum, value + step)
                ),
            )

            cy += 44

        canvas.text((x, cy, 140, 36), "调试视图", 13)

        mode = int(app.current.get("view_mode", 0))

        canvas.button(
            (x + 150, cy, width - 180, 36),
            DEBUG[mode] + " ⌄",
            lambda: app.open_modal("debug"),
        )
        canvas.unclip()
