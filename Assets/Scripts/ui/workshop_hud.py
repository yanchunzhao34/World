"""原三段顶栏、工具、笔刷与材料快捷栏。"""

from .material_tile import material_tile
from .workshop_style import INK, DIM, STATES, ACCENT


class WorkshopHud:
    def __init__(self, app):
        self.app = app

    def render(self, c):
        app, width, height = self.app, c.width, c.height
        has_logo, has_time = width >= 1250, width >= 1050
        scene_width = 250 if has_logo else 142
        transport_width = 510 if has_time else 300
        menu_width = 406 if width >= 1200 else 344
        c.rect((12, 12, scene_width, 52), "fffffff2", 14)
        c.regions.append((12, 12, scene_width, 52))
        start = 18
        if has_logo:
            c.icon((20, 26, 24, 24), "flask")
            c.text((50, 18, 100, 40), "元素工坊", 24, font=app.pixel_font)
            start = 150
        label = app.MAP_NAMES[app.MAPS.index(app.selected_map)] if app.selected_map in app.MAPS else app.selected_map
        c.button((start, 20, 112, 36), "场景  " + label + " ⌄", lambda: app.open_modal("scenes"), fill="ffffff00")
        gap = (width - 24 - scene_width - transport_width - menu_width) / 2
        tx = scene_width + 12 + max(8, gap)
        c.rect((tx, 12, transport_width, 52), "fffffff2", 14)
        c.regions.append((tx, 12, transport_width, 52))
        c.button((tx + 6, 18, 40, 40), "", app.toggle_pause, dark=True, identifier="pause")
        c.image((tx + 17, 29, 18, 18), "ui/vectors/" + ("play_white" if app.paused else "pause_white") + ".svg")
        c.button((tx + 52, 20, 32, 36), "", app.step_once, fill="ffffff00", identifier="single-step")
        c.image((tx + 59, 29, 18, 18), "ui/vectors/step.svg")
        c.rect((tx + 90, 22, 174, 32), "efeff2", 10)
        for index, value in enumerate((.25, .5, 1, 2, 4)):
            c.button((tx + 92 + 34 * index, 24, 32, 28), ["¼", "½", "1×", "2×", "4×"][index],
                     lambda value=value: app.set_speed(value), fill="ffffff" if app.speed == value else "ffffff00",
                     identifier="speed-" + str(value))
        seconds = app.current.get("tick", 0) // 60
        c.text((tx + 267, 20, 48, 36), "已暂停" if app.paused else f"{seconds // 60:02}:{seconds % 60:02}", 12, align=.5)
        if has_time:
            day = app.current.get("day", 10)
            c.text((tx + 320, 20, 57, 36), f"☀ {int(day):02}:{int(day % 1 * 60):02}", 12, DIM)
            c.slider((tx + 381, 25, 116, 26), day, 0, 24,
                     lambda value: app.send(dict(type="time", value=value)), "daylight")
        mx = width - 12 - menu_width
        if mx < tx + transport_width + 8:
            mx = width - 66
            c.button((mx, 20, 48, 36), "☰", lambda: app.open_modal("menu"), fill="fffffff2")
        else:
            c.rect((mx, 12, menu_width, 52), "fffffff2", 14)
            c.regions.append((mx, 12, menu_width, 52))
            count = app.codex.count_found()
            c.button((mx + 4, 20, 126, 36), f"图鉴  {count}/100", lambda: app.open_modal("codex"), fill="ffffff00")
            c.button((mx + 132, 20, 44, 36), "演示", lambda: app.open_modal("demos"), fill="ffffff00")
            c.button((mx + 178, 20, 44, 36), "存档", lambda: app.open_modal("save"), fill="ffffff00")
            icon_start = mx + 226
            for index, (key, action) in enumerate((("people", lambda: app.open_modal("network")),
                ("gear", lambda: app.open_modal("settings")), ("help", lambda: app.open_modal("help")), ("full", app.fullscreen))):
                x = icon_start + index * 36
                if x + 32 <= width - 16:
                    c.button((x, 20, 32, 36), "", action, fill="ffffff00", identifier="hud-" + key)
                    c.image((x + 7, 29, 18, 18), "ui/vectors/" + key + ".svg")
        tool_scale = min(1, (height - 94) / 610)
        for index, key in enumerate(app.TOOLS):
            rect = (12, 80 + index * 54 * tool_scale, 48 * tool_scale, 48 * tool_scale)
            c.button(rect, "", lambda index=index: app.select_tool(index), active=app.tool == index,
                     identifier="tool-" + key)
            c.icon((rect[0] + 12 * tool_scale, rect[1] + 9 * tool_scale, 24 * tool_scale, 24 * tool_scale), key)
            c.text((rect[0] + 31 * tool_scale, rect[1] + 32 * tool_scale, 12, 12), "BGEHCFX"[index], 9, DIM)
        by = 80 + 400 * tool_scale
        c.rect((12, by, 48 * tool_scale, 196 * tool_scale), "fffffff2", 14)
        c.regions.append((12, by, 48 * tool_scale, 196 * tool_scale))
        c.text((12, by + 3, 48 * tool_scale, 24 * tool_scale), "笔刷", 11, DIM, .5)
        c.text((12, by + 27 * tool_scale, 48 * tool_scale, 31 * tool_scale), "○" if app.shape == 0 else "□", 28, align=.5)
        c.text((12, by + 61 * tool_scale, 48 * tool_scale, 22 * tool_scale), f"{app.radius:g}", 18, align=.5)
        for index, delta in enumerate((-.5, .5)):
            c.button((14 + index * 23 * tool_scale, by + 86 * tool_scale, 21 * tool_scale, 22 * tool_scale),
                     "−" if delta < 0 else "+", lambda delta=delta: app.set_radius(app.radius + delta), size=13)
        for index in range(2):
            c.button((12 + index * 24 * tool_scale, by + 113 * tool_scale, 24 * tool_scale, 24 * tool_scale),
                     "●" if index == 0 else "■", lambda index=index: setattr(app, "shape", index),
                     active=app.shape == index, size=12)
        c.button((15, by + 145 * tool_scale, 42 * tool_scale, 22 * tool_scale),
                 "开" if app.overwrite else "关", lambda: setattr(app, "overwrite", not app.overwrite),
                 active=app.overwrite, size=11)
        c.text((12, by + 169 * tool_scale, 48 * tool_scale, 20 * tool_scale), "覆盖", 11, DIM, .5)
        self.render_dock(c)
        if app.current.get("demo"):
            c.button(((width - 150) / 2, 80, 150, 38), "结束演示 · Esc", lambda: app.send(dict(type="demo_stop")))
            c.text((100, height - 155, width - 200, 48), app.current.get("demo_caption", ""), 18, "ffffff", .5, wrap=True)

    def render_dock(self, c):
        app, width, height = self.app, c.width, c.height
        card_width = 258 if width >= 1100 else 0
        dock_width = card_width + 9 * 66 + 112 + 20
        x, y = (width - dock_width) / 2, height - 118
        c.rect((x, y, dock_width, 104), "fffffff2", 18)
        c.regions.append((x, y, dock_width, 104))
        if card_width:
            material = app.data["materials"][app.material_id]
            c.icon((x + 12, y + 24, 56, 56), material["key"])
            c.text((x + 80, y + 19, 160, 28), material["zh"], 18)
            facts = STATES[material["state"]]
            if material["state"] == "Solid" and material["hiTemp"] > 0:
                facts += f' · 熔点 {round(material["hiTemp"] - 273)}°C'
            elif material["state"] != "Solid":
                facts += f' · 密度 {material["density"]:g}'
            c.text((x + 80, y + 49, 166, 18), facts, 11, DIM)
            entries = app.codex.for_material(app.material_id)
            if entries:
                c.text((x + 80, y + 69, 166, 18), f"反应 {app.codex.count_found(entries)} / {len(entries)}", 11, "c2410c")
        sx = x + card_width + 10
        # Hotbar remains a drop target while the library is open.
        old_interactive = c.interactive
        c.interactive = old_interactive or app.modal == "library"
        for slot, key in enumerate(app.hotbar):
            material_tile(c, app, (sx + slot * 66, y + 10, 62, 84), app.material(key), slot)
        c.button((sx + 9 * 66 + 4, y + 10, 108, 84), "", lambda: app.toggle_modal("library"), dark=True,
                 identifier="material-library")
        c.image((sx + 9 * 66 + 46, y + 20, 24, 24), "ui/vectors/library.svg")
        c.text((sx + 9 * 66 + 4, y + 47, 108, 22), "物质库", 13, "ffffff", .5)
        c.text((sx + 9 * 66 + 4, y + 71, 108, 16), "85 种 · M", 11, "ffffff", .5)
        c.interactive = old_interactive
