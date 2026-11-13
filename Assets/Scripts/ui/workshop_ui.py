"""页面、输入、偏好与状态协调。模拟操作只经过 Runtime 队列。"""

import json
import math
import os
from pathlib import Path

from _infernux_packages.workshop.runtime.library.dependencies import tempfile, time

from Infernux.lib import InxGUIRenderable, InputManager
from Infernux.input import Input
from Infernux.engine.ui import imgui_keys as K

from .action_menu import action_menu
from .brush_overlay import draw_brush
from .codex_view import CodexView
from .discovery_codex import DiscoveryCodex
from .material_library import MaterialLibrary
from .probe_tooltip import draw_probe
from .title_view import TitleView
from .workshop_hud import WorkshopHud
from .workshop_settings import WorkshopSettings, DEBUG
from .workshop_style import Canvas, Images, INK, DIM


class WorkshopUI(InxGUIRenderable):
    MAPS = ["lab", "cave", "volcano", "gallery", "optics", "energy", "cover", "empty"]
    MAP_NAMES = ["实验室", "洞穴", "火山", "画廊", "光学台", "能量与发光", "彩窗大厅", "空白"]
    TOOLS = ["brush", "spray", "eraser", "heat", "cool", "ignite", "explode"]
    HOT = ["sand", "water", "fire", "lava", "acid", "sodium", "iron", "ice", "gunpowder"]

    def __init__(self, frontend, runtime, presentation, sound, root, user_directory,
                 map_key=None, paused=False, editor_panel=None):
        super().__init__()
        self.frontend, self.native = frontend, frontend.get_native_engine()
        self.runtime, self.presentation, self.sound = runtime, presentation, sound
        self.editor_panel = editor_panel
        self.root, self.assets, self.user_directory = root, root / "Assets/Workshop", Path(user_directory)
        self.data = json.loads((self.assets / "original/data/game.json").read_text("utf-8"))
        self.english_names = json.loads((self.assets / "ui/material_names.json").read_text("utf-8"))
        self.demos = json.loads((self.assets / "ui/demos.json").read_text("utf-8"))
        self.settings = dict(self.data["renderSettings"])
        self.by_key = {m["key"]: m for m in self.data["materials"]}
        self.font = Path(os.environ.get("WINDIR", r"C:\Windows")) / "Fonts/msyh.ttc"
        self.bold_font = self.font.parent / "msyhbd.ttc"
        self.latin_bold_font = self.font.parent / "segoeuib.ttf"
        self.pixel_font = self.assets / "original/fonts/ui.ttf"
        self.images = Images(self.native, self.assets)
        self.codex = DiscoveryCodex(self.data)
        self.hotbar, self.favorites, self.recent = list(self.HOT), [], []
        self.home_language = "zh"
        self.load_ui_state()
        self.selected_map, self.playing = map_key or "lab", map_key is not None
        self.material_id, self.tool, self.radius, self.shape, self.overwrite = 14, 0, 4, 0, False
        self.paused, self.speed, self.current = paused, 1, {}
        self.modal, self.text_focus, self.menu_scroll = "", "", 0
        self.title, self.hud = TitleView(self), WorkshopHud(self)
        self.library, self.codex_view = MaterialLibrary(self), CodexView(self)
        self.settings_view = WorkshopSettings(self)
        self.dimensions, self.widgets = (0, 0), {}
        self.drawing, self.panning, self.straight, self.erasing = False, False, False, False
        self.origin, self.last, self.previous_mouse = (0, 0), (0, 0), (0, 0)
        self.drag_source, self.dragging = None, False
        self.probe_sequence, self.probe_pending = 0, 0
        self.probe_sample, self.probe_received, self.probe_sent = {}, 0, 0
        self.error, self.fullscreen_enabled = "", False
        self.last_render = time.monotonic()
        self.paint_elapsed = 0.0
        self.select_material(14)

    def send(self, action):
        if action["type"] in ("load", "restore", "resize", "fit", "pan", "zoom", "yaw", "debug"):
            self.invalidate_probe()
        self.runtime.send_action(action)

    def material(self, key):
        return self.by_key.get(key, self.data["materials"][0])

    def invalidate_probe(self):
        self.probe_sample, self.probe_pending = {}, 0

    def select_scene(self, key):
        self.selected_map = key

    def start_game(self, key):
        self.close_modal()
        self.playing = True
        self.sound.enable()
        self.load_map(key)

    def show_title(self):
        self.close_modal()
        self.playing = False
        self.drawing, self.panning, self.straight = False, False, False
        self.codex.previous = {}
        self.send(dict(type="load", map="titlelab"))
        self.send(dict(type="pause", value=False))

    def load_map(self, key):
        self.selected_map, self.paused = key, False
        self.codex.previous = {}
        self.send(dict(type="load", map=key))
        self.send(dict(type="pause", value=False))
        self.resize_view(*self.dimensions)

    def resize_view(self, width, height):
        if width > 0 and height > 0:
            self.send(dict(type="resize", width=width, height=height))

    def toggle_pause(self):
        self.paused = not self.paused
        self.send(dict(type="pause", value=self.paused))

    def step_once(self):
        self.paused = True
        self.send(dict(type="pause", value=True))
        self.send(dict(type="step"))

    def set_speed(self, value):
        self.speed = value
        self.send(dict(type="speed", value=value))

    def set_setting(self, key, value):
        if self.settings[key] != value:
            self.settings[key] = value
            self.send(dict(type="setting", key=key, value=value))
            if key == "ViewHeight":
                self.resize_view(*self.dimensions)

    def set_radius(self, value):
        self.radius = min(80, max(.5, value))

    def select_tool(self, index):
        self.tool = index

    def select_material(self, identifier):
        self.material_id = identifier
        key = self.data["materials"][identifier]["key"]
        self.recent = [key] + [item for item in self.recent if item != key][:11]
        if self.tool > 1:
            self.tool = 0
        if hasattr(self, "library"):
            self.library.detail_scroll = 0
        self.save_ui_state()

    def assign_hotbar(self, index, identifier):
        key = self.data["materials"][identifier]["key"]
        if key in self.hotbar:
            existing = self.hotbar.index(key)
            self.hotbar[existing] = self.hotbar[index]
        self.hotbar[index] = key
        self.save_ui_state()

    def toggle_favorite(self, key):
        if key in self.favorites:
            self.favorites.remove(key)
        else:
            self.favorites.append(key)
        self.save_ui_state()

    def load_ui_state(self):
        path = self.user_directory / "workshop_ui.json"
        if not path.exists():
            return
        try:
            saved = json.loads(path.read_text("utf-8"))
        except (OSError, ValueError):
            return
        if not isinstance(saved, dict):
            return
        # 按当前材料表过滤旧偏好，避免数据升级后引用失效物质
        valid = {m["key"] for m in self.data["materials"] if m["id"] > 0 and not m["hidden"]}
        if saved.get("home_language") in ("zh", "zh-TW", "en"):
            self.home_language = saved["home_language"]
        hotbar = saved.get("hotbar")
        if isinstance(hotbar, list) and len(hotbar) == 9:
            self.hotbar = [key if isinstance(key, str) and key in valid else self.HOT[i] for i, key in enumerate(hotbar)]
        for name in ("favorites", "recent"):
            values = saved.get(name, [])
            if isinstance(values, list):
                setattr(self, name, list(dict.fromkeys(v for v in values if isinstance(v, str) and v in valid)))
        self.recent = self.recent[:12]
        discoveries = saved.get("discoveries", [])
        if isinstance(discoveries, list):
            identifiers = {e["id"] for e in self.codex.entries}
            self.codex.found = {v for v in discoveries if isinstance(v, str) and v in identifiers}

    def save_ui_state(self):
        self.user_directory.mkdir(parents=True, exist_ok=True)
        payload = dict(version=1, hotbar=self.hotbar, favorites=self.favorites, recent=self.recent,
                       discoveries=sorted(self.codex.found), home_language=self.home_language)
        descriptor, name = tempfile.mkstemp(suffix=".tmp", dir=self.user_directory)
        try:
            with os.fdopen(descriptor, "w", encoding="utf-8") as stream:
                json.dump(payload, stream, ensure_ascii=False)
            # 原子替换偏好文件，避免程序中断留下截断的JSON
            os.replace(name, self.user_directory / "workshop_ui.json")
        finally:
            Path(name).unlink(missing_ok=True)

    def open_modal(self, name):
        self.focus_text("")
        self.modal, self.menu_scroll = name, 0
        # 打开面板时终止画笔状态，避免关闭后沿旧起点继续绘制
        self.drawing, self.panning, self.straight = False, False, False
        self.invalidate_probe()

    def close_modal(self):
        self.modal = ""
        self.focus_text("")

    def toggle_modal(self, name):
        self.close_modal() if self.modal == name else self.open_modal(name)

    def focus_text(self, name):
        self.text_focus = name
        manager = InputManager.instance()
        manager.start_text_input() if name else manager.stop_text_input()

    def fullscreen(self):
        self.fullscreen_enabled = not self.fullscreen_enabled
        self.native.set_fullscreen(self.fullscreen_enabled)

    def paint(self, start, end):
        self.send(dict(type="paint", x0=start[0], y0=start[1], x1=end[0], y1=end[1],
                       material=self.material_id, tool=2 if self.erasing else self.tool,
                       radius=self.radius, shape=self.shape, overwrite=self.overwrite))

    def update(self, wait_for_frame=False):
        """Consume simulation frames independently of cached editor GUI draws."""
        now = time.monotonic()
        # 限时等待与产帧节奏对齐，减少双时钟竞争造成的重复帧
        timeout = 1 / 60 if wait_for_frame and self.current else 0
        frame = self.runtime.latest(timeout=timeout)
        if frame is not None:
            self.current = frame.state
            self.paused = bool(frame.state["paused"])
            self.sound.update(self.current)
            probe = frame.state.get("probe", {})
            if self.probe_pending and probe.get("request_id") == self.probe_pending:
                # 按请求号接纳结果，避免较早探针覆盖当前鼠标位置
                self.probe_sample = probe
                self.probe_received, self.probe_pending = now, 0
            # 图鉴只记录玩家实验，避免主页与演示自动解锁条目
            if self.playing and not self.current.get("demo") and self.current.get("map") != "titlelab":
                if self.codex.update(self.current):
                    self.save_ui_state()
            else:
                self.codex.previous = {}
        while not self.runtime.errors.empty():
            self.error = self.runtime.errors.get()
            print(self.error, flush=True)
        self.presentation.update(frame, max(1, self.dimensions[0]), max(1, self.dimensions[1]))

    def on_render(self, ctx):
        now = time.monotonic()
        self.paint_elapsed += now - self.last_render
        if self.editor_panel is None:
            self.update(wait_for_frame=True)
        if self.editor_panel is not None:
            # 将叠加界面限定在游戏视图内，避免遮挡其他编辑器面板
            if not self.editor_panel.is_content_visible():
                self.drawing = self.panning = self.straight = False
                self.last_render = now
                return
            width, height = Input.game_viewport_size
            mx, my = Input.mouse_position
            gx, gy = Input.game_mouse_position
            x, y = mx - gx, my - gy
        else:
            x, y, width, height = ctx.get_main_viewport_bounds()
        width, height = max(1, round(width)), max(1, round(height))
        if self.dimensions != (width, height):
            self.dimensions = width, height
            if self.editor_panel is None:
                self.frontend.resize_game_render_target(width, height)
            self.resize_view(width, height)
        self.presentation.update(None, width, height)
        child_open = False
        if self.editor_panel is not None:
            # 复用游戏视图子窗口，避免聚焦切换时界面被压到后方
            visible = ctx.begin_window("game_view", True, 0)
            if visible:
                visible = ctx.begin_child("##GameViewportRegion", 0, 0, False)
                child_open = True
                ctx.push_draw_list_clip_rect(x, y, x + width, y + height, True)
        else:
            ctx.set_next_window_pos(x, y, 0, 0, 0)
            ctx.set_next_window_size(width, height, 0)
            ctx.push_style_var_vec2(2, 0, 0)
            ctx.push_style_var_float(4, 0)
            flags = sum(1 << bit for bit in (0, 1, 2, 3, 5, 8, 16, 17, 19))
            visible = ctx.begin_window("##ElementWorkshop", True, flags)
        try:
            if visible:
                ctx.draw_image_rect(self.frontend.get_game_texture_id(), x, y, x + width, y + height)
                scale = round(max(1, min(2.5, min(width / 1600, height / 900))) * 20) / 20
                canvas = Canvas(ctx, self, x, y, width, height, scale)
                # 游戏视图占用活动项时仍接收同层输入，避免按钮失效
                canvas.input_enabled = (self.editor_panel is None or
                                        ctx.is_window_hovered(1 << 7))
                self.widgets = {}
                if self.editor_panel is None or Input.is_game_focused():
                    self.keyboard(ctx)
                canvas.interactive = not bool(self.modal)
                self.hud.render(canvas) if self.playing else self.title.render(canvas)
                if self.modal:
                    canvas.interactive = True
                    self.render_modal(canvas)
                self.process_pointer(canvas, now)
                if not self.current:
                    canvas.text((26, 90, canvas.width - 52, 40), "正在加载场景和着色器…", 22, "ffffff")
                if self.error:
                    canvas.rect((18, 80, canvas.width - 36, 120), "280c11eb", 12)
                    canvas.text((30, 86, canvas.width - 60, 108), self.error, 13, "ff9c9c", wrap=True)
                if self.dragging and self.drag_source:
                    material = self.data["materials"][self.drag_source["material"]]
                    canvas.icon((canvas.mouse[0] - 20, canvas.mouse[1] - 20, 40, 40), material["key"])
                if not ctx.is_mouse_button_down(0):
                    self.drag_source, self.dragging = None, False
        finally:
            if child_open:
                ctx.pop_draw_list_clip_rect()
                ctx.end_child()
            ctx.end_window()
            if self.editor_panel is None:
                ctx.pop_style_var(2)
        self.last_render = now

    def keyboard(self, ctx):
        if ctx.is_key_pressed(K.KEY_ESCAPE):
            if self.modal == "library" and self.library.query:
                self.library.query = ""
            else:
                self.close_modal()
                self.send(dict(type="demo_stop"))
            return
        if self.text_focus:
            # 文本输入优先消费按键，避免搜索时触发游戏快捷键
            view = self.library if self.text_focus == "library-search" else self.codex_view
            value = InputManager.instance().input_string
            control = ctx.is_key_down(K.KEY_LEFT_CTRL) or ctx.is_key_down(K.KEY_RIGHT_CTRL)
            if control and ctx.is_key_pressed(K.KEY_A):
                view.query = ""
            elif control and ctx.is_key_pressed(K.KEY_V):
                view.query += ctx.get_clipboard_text()
            elif value and not control:
                view.query += value
            if ctx.is_key_pressed(K.KEY_BACKSPACE):
                view.query = view.query[:-1]
            if ctx.is_key_pressed(K.KEY_ENTER):
                if self.modal == "library":
                    materials = [m for _, group in self.library.groups() for m in group]
                    if materials:
                        self.select_material(materials[0]["id"])
                self.focus_text("")
            return
        if self.modal:
            if self.modal == "library":
                if ctx.is_key_pressed(600):
                    self.focus_text("library-search")
                if ctx.is_key_pressed(K.KEY_M):
                    self.close_modal()
                for slot in range(9):
                    if ctx.is_key_pressed(K.KEY_1 + slot):
                        self.assign_hotbar(slot, self.material_id)
            return
        if not self.playing:
            if ctx.is_key_pressed(K.KEY_ENTER) or ctx.is_key_pressed(K.KEY_SPACE):
                self.start_game(self.selected_map)
            return
        control = ctx.is_key_down(K.KEY_LEFT_CTRL) or ctx.is_key_down(K.KEY_RIGHT_CTRL)
        if control:
            if ctx.is_key_pressed(K.KEY_S):
                self.send(dict(type="save"))
            if ctx.is_key_pressed(K.KEY_L):
                self.send(dict(type="restore"))
            return
        shortcuts = {K.KEY_SPACE: self.toggle_pause, K.KEY_N: self.step_once,
                     599: self.step_once,
                     K.KEY_M: lambda: self.toggle_modal("library"), K.KEY_TAB: lambda: self.open_modal("codex"),
                     K.KEY_HOME: lambda: self.send(dict(type="fit")),
                     K.KEY_Q: lambda: self.send(dict(type="yaw", value=-3)),
                     K.KEY_R: lambda: self.send(dict(type="yaw", value=3))}
        for key, callback in shortcuts.items():
            if ctx.is_key_pressed(key):
                callback()
        for index, key in enumerate((K.KEY_B, K.KEY_G, K.KEY_E, K.KEY_H, K.KEY_C, K.KEY_F, K.KEY_X)):
            if ctx.is_key_pressed(key):
                self.select_tool(index)
        for slot, key in enumerate(self.hotbar):
            if ctx.is_key_pressed(K.KEY_1 + slot):
                self.select_material(self.material(key)["id"])

    def process_pointer(self, c, now):
        ctx = c.ctx
        point = tuple(value * c.scale for value in c.mouse)
        inside = 0 <= c.mouse[0] < c.width and 0 <= c.mouse[1] < c.height
        # 控件区域拦截世界操作，避免点击界面时同时绘制材料
        blocked = not inside or bool(self.modal) or any(c.hit(rect) for rect in c.regions)
        focused = (Input.is_game_focused() if self.editor_panel is not None else
                   ctx.is_window_focused(1 << 2))
        if self.drag_source and ctx.is_mouse_button_down(0):
            self.dragging = math.dist(c.mouse, self.drag_source["origin"]) > 5
        if not self.playing or not focused:
            self.drawing, self.panning, self.straight = False, False, False
            self.invalidate_probe()
            return
        shift = ctx.is_key_down(K.KEY_LEFT_SHIFT) or ctx.is_key_down(K.KEY_RIGHT_SHIFT)
        alt = ctx.is_key_down(K.KEY_LEFT_ALT) or ctx.is_key_down(K.KEY_RIGHT_ALT)
        left, right, middle = (ctx.is_mouse_button_down(i) for i in (0, 1, 2))
        if self.drawing and not left and not right:
            if self.straight:
                self.paint(self.origin, point)
            self.drawing, self.straight = False, False
        if self.panning and not middle and not (left and alt):
            self.panning = False
        if self.panning:
            self.send(dict(type="pan", x=point[0] - self.previous_mouse[0], y=point[1] - self.previous_mouse[1]))
        if blocked:
            self.invalidate_probe()
            self.previous_mouse = point
            return
        wheel = ctx.get_mouse_wheel_delta()
        if wheel:
            if shift:
                self.set_radius(self.radius + .5 * wheel)
            else:
                self.send(dict(type="zoom", x=point[0], y=point[1], factor=1.15 ** wheel))
        if ctx.is_mouse_button_clicked(2) or (ctx.is_mouse_button_clicked(0) and alt):
            self.panning = True
        elif ctx.is_mouse_button_clicked(0) or ctx.is_mouse_button_clicked(1):
            self.erasing = ctx.is_mouse_button_clicked(1)
            self.drawing, self.straight = True, shift
            self.origin, self.last = point, point
            if not shift:
                self.paint(point, point)
            if self.tool == 6:
                self.drawing = False
        # 按模拟频率采样拖动，避免高界面帧率挤满画笔队列
        if self.drawing and not self.straight and self.paint_elapsed > 1 / 60:
            self.paint(self.last, point)
            self.last = point
            self.paint_elapsed = 0.0
        if self.current:
            draw_brush(c, self)
            draw_probe(c, self, now)
        # 探针限频并允许超时重试，兼顾GPU开销与悬停反馈
        if self.current and now - self.probe_sent >= .08 and (not self.probe_pending or now - self.probe_sent > .5):
            self.probe_sequence += 1
            self.probe_pending, self.probe_sent = self.probe_sequence, now
            self.send(dict(type="probe", x=point[0], y=point[1], request_id=self.probe_pending))
        self.previous_mouse = point

    def render_modal(self, c):
        if self.modal == "library":
            self.library.render(c)
            return
        c.rect((0, 0, c.width, c.height), "00000055")
        if self.modal == "codex":
            self.codex_view.render(c)
            return
        titles = {"scenes": "场景", "demos": "演示", "save": "存档", "network": "多人联机",
                  "settings": "画面设置", "help": "操作说明", "language": "语言 / Language",
                  "menu": "菜单", "debug": "调试视图"}
        width = min(840, c.width - 48)
        height = min(660, c.height - 48)
        x, y = (c.width - width) / 2, (c.height - height) / 2
        c.rect((x, y, width, height), "ffffff", 18)
        c.regions.append((x, y, width, height))
        c.text((x + 20, y + 16, width - 90, 36), titles.get(self.modal, self.modal), 22)
        c.button((x + width - 56, y + 16, 36, 36), "×", self.close_modal)
        rect = x + 20, y + 72, width - 40, height - 92
        if self.modal == "settings":
            self.settings_view.render(c, rect)
            return
        if self.modal == "network":
            c.text(rect, "原版的房间服务和多人同步尚未移植。当前版本支持单人实验。", 15, wrap=True)
            return
        if self.modal == "help":
            c.text(rect, "左键绘制，右键擦除；Shift + 拖动绘制直线。\n滚轮缩放，Shift + 滚轮调整笔刷。\n中键或 Alt + 左键平移。\n\nB 笔刷 · G 喷枪 · E 橡皮 · H 加热 · C 降温 · F 点燃 · X 爆炸\n1–9 常用物质 · M 物质库\n空格暂停 · N 单步 · Home 适应画面\nCtrl+S 保存 · Ctrl+L 读取 · Esc 关闭面板", 19, wrap=True)
            return
        if self.modal == "save":
            items = [("保存快速存档", lambda: self.save_action("save")),
                     ("读取快速存档", lambda: self.save_action("restore"))]
            c.text((rect[0], rect[1], rect[2], 36), "保存材料、温度与背景；读取时重新建立刚体。", 17)
            rect = rect[0], rect[1] + 48, rect[2], rect[3] - 48
        elif self.modal == "scenes":
            items = [(name, lambda key=key: self.menu_load(key)) for key, name in zip(self.MAPS, self.MAP_NAMES)]
            items += [("重置当前场景", lambda: self.menu_load(self.selected_map)),
                      ("清空世界", lambda: self.save_action("clear"))]
        elif self.modal == "demos":
            items = [("▶ " + demo["title"], lambda demo=demo: self.play_demo(demo)) for demo in self.demos]
        elif self.modal == "language":
            items = [(label, lambda key=key: self.set_language(key))
                     for key, label in (("zh", "简体中文"), ("zh-TW", "繁體中文"), ("en", "English"))]
        elif self.modal == "debug":
            items = [(name, lambda mode=mode: self.debug_view(mode)) for mode, name in enumerate(DEBUG)]
        else:
            items = [(label, lambda name=name: self.open_modal(name)) for name, label in (
                ("codex", "图鉴"), ("demos", "演示"), ("save", "存档"), ("network", "联机"),
                ("settings", "设置"), ("help", "帮助"))]
            items.append(("全屏", self.fullscreen))
        action_menu(c, self, rect, items)

    def menu_load(self, key):
        self.close_modal()
        self.load_map(key)

    def play_demo(self, item):
        self.close_modal()
        self.selected_map = item["scene"]
        self.send(dict(type="demo", key=item["key"]))

    def save_action(self, action):
        self.close_modal()
        self.send(dict(type=action))

    def debug_view(self, mode):
        self.close_modal()
        self.send(dict(type="debug", value=mode))

    def set_language(self, key):
        self.home_language = key
        self.close_modal()
        self.save_ui_state()

    def close(self):
        self.focus_text("")
        self.images.close()
