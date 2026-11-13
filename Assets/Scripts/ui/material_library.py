"""三栏物质库，保留分类、搜索、详情、收藏、最近使用和拖放。"""

import math

from .material_tile import material_tile
from .workshop_style import DIM, INK, STATES, ACCENT

CATEGORIES = ["Powder", "Liquid", "Gas", "Energy", "Solid", "Special"]


class MaterialLibrary:
    def __init__(self, app):
        self.app = app
        self.category = "all"
        self.query = ""
        self.scroll = 0
        self.detail_scroll = 0

    def usable(self):
        return [m for m in self.app.data["materials"] if m["id"] > 0 and not m["hidden"]]

    def groups(self):
        app = self.app
        if self.query.strip():
            query = self.query.lower()
            # 同时匹配显示名与稳定键名，便于跨语言查找同一物质
            return [("搜索结果", [m for m in self.usable() if query in (
                m["zh"] + " " + m["key"] + " " + app.english_names.get(m["key"], "")).lower()])]
        if self.category in ("recent", "fav"):
            keys = app.recent if self.category == "recent" else app.favorites
            return [("最近使用" if self.category == "recent" else "收藏", [app.material(key) for key in keys])]
        return [(STATES[key], [m for m in self.usable() if m["category"] == key])
                for key in (CATEGORIES if self.category == "all" else [self.category])]

    def select_category(self, key):
        self.category, self.scroll = key, 0

    def render(self, c):
        app = self.app
        width, height = min(1220, c.width - 32), min(752, c.height - 150)
        x, y = (c.width - width) / 2, c.height - 120 - height
        c.rect((x, y, width, height), "ffffff", 20)
        c.regions.append((x, y, width, height))
        c.text((x + 16, y + 12, 76, 48), "物质库", 20, font=app.bold_font)
        if c.width >= 1100:
            c.text((x + 92, y + 12, 520, 48), "拖到下方快捷栏，或选中后按数字键 1–9 放入", 12, DIM)
        search_width = 320 if c.width >= 1100 else 230
        c.search((x + width - search_width - 68, y + 16, search_width, 40), self.query,
                 "⌕  搜索：中文 / English             /", "library-search")
        c.button((x + width - 52, y + 16, 36, 40), "×", app.close_modal, identifier="close-library")
        c.rect((x, y + 72, width, 1), "e7e7ec")
        category_width = 180 if c.width >= 1100 else 140
        detail_width = 330 if c.width >= 1200 else 270
        grid_x = x + category_width + 18
        detail_x = x + width - detail_width
        grid_width = detail_x - grid_x - 18
        bottom = y + height
        c.rect((x + category_width, y + 72, 1, height - 72), "e7e7ec")
        c.rect((detail_x, y + 72, 1, height - 72), "e7e7ec")
        cats = [("all", "全部", len(self.usable())), ("recent", "最近使用", len(app.recent)),
                ("fav", "收藏", len(app.favorites))]
        cats += [(key, STATES[key], sum(m["category"] == key for m in self.usable())) for key in CATEGORIES]
        for index, (key, label, count) in enumerate(cats):
            cy = y + 84 + index * 42
            c.button((x + 12, cy, category_width - 24, 38), "",
                     lambda key=key: self.select_category(key),
                     fill="f1f1f4" if self.category == key else "ffffff00", identifier="category-" + key)
            c.text((x + 24, cy, category_width - 72, 38), label, 13)
            c.text((x + category_width - 50, cy, 26, 38), count, 12, DIM, 1)
        clip = grid_x, y + 82, grid_width, height - 90
        columns = max(1, int((grid_width + 6) / 72))
        groups = self.groups()
        content_height = sum(38 + math.ceil(len(items) / columns) * 88 for _, items in groups)
        self.scroll = max(0, min(self.scroll, max(0, content_height - clip[3])))
        if c.hit(clip):
            self.scroll = max(0, min(max(0, content_height - clip[3]),
                                     self.scroll - c.ctx.get_mouse_wheel_delta() * 52))
        c.clip(clip)
        gy = y + 84 - self.scroll
        for label, items in groups:
            c.text((grid_x, gy, grid_width, 24), f"{label}  {len(items)}", 13)
            gy += 28
            for index, material in enumerate(items):
                tx, ty = grid_x + (index % columns) * 72, gy + (index // columns) * 88
                if ty + 82 >= clip[1] and ty < bottom:
                    # 仅为可见行生成交互项，降低长物质列表的绘制开销
                    material_tile(c, app, (tx, ty, 66, 82), material)
            gy += math.ceil(len(items) / columns) * 88 + 10
        c.unclip()
        if content_height > clip[3]:
            bar_height = max(24, clip[3] * clip[3] / content_height)
            bar_y = clip[1] + self.scroll / (content_height - clip[3]) * (clip[3] - bar_height)
            c.rect((detail_x - 7, bar_y, 6, bar_height), "aaaaaa", 3)
        self.render_detail(c, (detail_x + 20, y + 92, detail_width - 40, height - 112))

    def render_detail(self, c, rect):
        app, (x, y, width, height) = self.app, rect
        material = app.data["materials"][app.material_id]
        clip = x, y, width, max(80, height - 106)
        props = [("状态", STATES[material["state"]])]
        if material["state"] != "Solid":
            props.append(("密度", f'{material["density"]:g}'))
        props.append(("初始温度", f'{round(material["defaultTemp"] - 273)} °C'))
        if material["hiTemp"] > 0:
            props.append(("沸腾" if material["state"] == "Liquid" else "熔化",
                f'{round(material["hiTemp"] - 273)} °C → {app.material(material["hiTo"])["zh"]}'))
        if material["loTemp"] > 0:
            props.append(("冷凝" if material["state"] == "Gas" else "凝固",
                f'{round(material["loTemp"] - 273)} °C → {app.material(material["loTo"])["zh"]}'))
        if material["flags"] & 1:
            props.append(("着火点", f'{round(material["igniteTemp"] - 273)} °C'))
        if material["flags"] & 2:
            props.append(("特性", "易爆"))
        if material["flags"] & 4:
            props.append(("特性", "可灭火"))
        entries = app.codex.for_material(app.material_id)
        content_height = 108 + len(props) * 49 + 46 + min(6, len(entries)) * 44
        maximum = max(0, content_height - clip[3])
        self.detail_scroll = max(0, min(maximum, self.detail_scroll))
        if c.hit(clip):
            self.detail_scroll = max(0, min(maximum, self.detail_scroll - c.ctx.get_mouse_wheel_delta() * 40))
        c.clip(clip)
        top = y - self.detail_scroll
        c.rect((x, top, 88, 88), "f1f1f4", 18)
        c.icon((x + 12, top + 12, 64, 64), material["key"])
        c.text((x + 104, top + 10, width - 104, 42), material["zh"], 26, font=app.bold_font)
        c.text((x + 104, top + 52, width - 104, 24), app.english_names.get(material["key"], material["key"]), 13, DIM)
        py = top + 100
        for name, value in props:
            c.rect((x, py, width, 1), "e7e7ec")
            c.text((x, py + 5, 62, 42), name, 12, DIM)
            c.text((x + 66, py + 5, width - 66, 42), value, 12, wrap=True)
            py += 49
        c.rect((x, py, width, 1), "e7e7ec")
        c.text((x, py + 9, width, 28), f"能参与的反应    已发现 {app.codex.count_found(entries)} / {len(entries)}", 12)
        py += 40
        for entry in sorted(entries, key=lambda e: e["id"] not in app.codex.found)[:6]:
            text = app.codex.description(entry) if entry["id"] in app.codex.found else (
                app.codex.title(entry) + "  还没发现")
            c.text((x, py, width, 40), text, 12, DIM, wrap=True)
            py += 44
        if not entries:
            c.text((x, py, width, 28), "暂时没有记录的反应", 12, DIM)
        c.unclip()
        footer_y = y + height - 97
        c.text((x, footer_y, width, 22), "放到快捷栏", 12, DIM)
        for slot in range(9):
            c.button((x + slot * (width / 9), footer_y + 25, width / 9 - 3, 28), str(slot + 1),
                     lambda slot=slot: app.assign_hotbar(slot, app.material_id), size=12,
                     identifier="assign-slot-" + str(slot))
        c.button((x, footer_y + 62, width, 36),
                 "★ 已收藏" if material["key"] in app.favorites else "☆ 收藏",
                 lambda: app.toggle_favorite(material["key"]), size=13, identifier="favorite")
