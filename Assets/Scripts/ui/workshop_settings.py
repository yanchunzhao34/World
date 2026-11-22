"""原设置键、范围及调试视图。界面通过操作协议更新后台。"""

from numpy import identity


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


SECTIONS = {
    "常规": (
        ("音量与亮度", ("volume", "WorldBrightness")),
        ("画面选项", ("Enable3D", "VoxelExtrude", "ViewHeight", "BgSmooth")),
    ),
    "光影": (
        ("环境光照", ("DayCycleOn", "AutoExposure", "BilinearFix", "Daylight")),
        ("光束与特效", ("BloomIntensity", "MirrorBeams", "LampBeams", "HeatDistortion", "Grain")),
    ),
    "调试": (("渲染视图", DEBUG),),
}


class WorkshopSettings:
    def __init__(self, app):
        self.app = app
        self.tab = "常规"
        self.scroll = 0
       

    def select_tab(self, tab):
        self.tab = tab
        self.scroll = 0
        self.app.menu_capture = None

    def draw_option(self, c, rect, key):
        app = self.app
        x, y, w, h = rect
        if self.tab == "调试":
            mode = DEBUG.index(key)
            selected = mode == app.current.get("view_mode", 0)
            c.menu_button(rect, key, lambda: app.debug_view(mode), "debug-" + str(mode),
                          primary=selected, size=14)
            return

        if key in SWITCHES:
            enabled = bool(app.settings[key])
            c.button(rect, "", lambda: app.set_setting(key, not enabled),
                     identifier="setting-" + key, fill="363d33", hover_fill="485243",
                     border="586052", rounding=0)
            c.text((x + 12, y, w - 84, h), SWITCHES[key], 15, "f0f1e7")
            switch = (x + w - 60, y + (h - 26) / 2, 50, 26)
            c.bevel(switch, "49693c" if enabled else "4b5049",
                    "92a780" if enabled else "757b70", "2e352c")
            c.text(switch, "开" if enabled else "关", 13, "f5f5e9", 0.5)
            return

        volume = key == "volume"
        if volume:
            label, minimum, maximum, step = "主音量", 0, 1, 0.01
            value = app.sound.volume
            display = f"{value:.0%}"
        else:
            label, minimum, maximum, step = KNOBS[key]
            value = app.settings[key]
            display = f"{value:g}"

        def change(new_value):
            snapped = round(minimum + round((new_value - minimum) / step) * step, 4)
            snapped = max(minimum, min(maximum, snapped))
            if volume:
                app.sound.volume = snapped
            else:
                app.set_setting(key, snapped)

        c.rect(rect, "30362f", border="50584c")
        c.text((x + 12, y + 2, w - 95, 24), label, 14, "edeFE4")
        c.text((x + w - 80, y + 2, 68, 24), display, 14, "c0dd92", 1)
        control_y = y + h - 27
        c.menu_button((x + 8, control_y, 26, 22), "-", lambda: change(value - step),
                      "minus-" + key, size=14)
        c.slider((x + 41, control_y, w - 82, 22), value, minimum, maximum, change,
                 "volume" if volume else "slider-" + key, block_style=True)
        c.menu_button((x + w - 34, control_y, 26, 22), "+", lambda: change(value + step),
                      "plus-" + key, size=14)

    def render(self, c):
        x, y, w, h = c.menu_frame("设置", "ui/vectors/gear.svg", 780, 500)
        if w < 120 or h < 54:
            return
        tab_w = (w - 12) / 3
        for index, tab in enumerate(SECTIONS):
            c.menu_button((x + index * (tab_w + 6), y, tab_w, 34), tab,
                          lambda tab=tab: self.select_tab(tab), "settings-tab-" + tab,
                          primary=tab == self.tab, size=15)

        body = x, y + 40, w, h - 40
        c.rect(body, "242a24", border="5d6658")
        inner = x + 8, y + 48, w - 16, h - 56
        list_x, list_y, list_w, list_h = inner
        columns = 2 if list_w >= 530 else 1
        row_h = 40 if self.tab == "调试" else 58
        sections = SECTIONS[self.tab]
        content_h = sum(32 + ((len(keys) + columns - 1) // columns) * (row_h + 6)
                        for _, keys in sections)
        self.scroll = c.menu_scroll(inner, self.scroll, content_h, "settings-scroll", row_h)
        if content_h > list_h:
            list_w -= 17
        option_w = (list_w - (columns - 1) * 6) / columns
        c.clip((list_x, list_y, list_w, list_h))
        cy = list_y - self.scroll
        for heading, keys in sections:
            if cy + 30 > list_y and cy < list_y + list_h:
                c.rect((list_x + 3, cy + 9, 3, 12), "9bbf75")
                c.text((list_x + 14, cy, list_w - 20, 30), heading, 14, "c9d1be",
                       font=self.app.bold_font)
            cy += 32
            for index, key in enumerate(keys):
                row, column = divmod(index, columns)
                row_y = cy + row * (row_h + 6)
                if row_y + row_h > list_y and row_y < list_y + list_h:
                    self.draw_option(c, (list_x + column * (option_w + 6), row_y, option_w, row_h), key)
            cy += ((len(keys) + columns - 1) // columns) * (row_h + 6)
        c.unclip()

        footer_y = y + h + 10
        button_w = min(170, (w - 8) / 2)
        c.menu_button((x, footer_y, button_w, 38), "结束游戏", self.app.request_exit, "exit-game")
        c.menu_button((x + w - button_w, footer_y, button_w, 38), "完成",
                      self.app.close_modal, "settings-done", primary=True)
        if self.app.playing:
            c.menu_button(
                (x+(w-button_w)/2,footer_y,button_w,38),
                "返回菜单",
                self.app.show_mode_page,
                identifier="settings-back-to-menu",
            )
