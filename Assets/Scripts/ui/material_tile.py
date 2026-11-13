"""物质库及快捷栏共用按钮，拖放由总协调器处理。"""

import math

from .workshop_style import DIM


def material_tile(canvas, app, rect, material, slot=-1):
    x, y, width, height = rect
    identifier = material["id"]
    canvas.button(rect, "", lambda: app.select_material(identifier),
                  active=identifier == app.material_id,
                  identifier=f"slot-{slot}" if slot >= 0 else f"material-{identifier}")
    canvas.icon((x + (width - 32) / 2, y + 14, 32, 32), material["key"])
    canvas.text((x + 2, y + 48, width - 4, 24), material["zh"], 11, align=.5)
    assigned = app.hotbar.index(material["key"]) if material["key"] in app.hotbar else -1
    badge = str(slot + 1) if slot >= 0 else str(assigned + 1) if assigned >= 0 else ""
    canvas.text((x + 6, y + 1, width - 12, 14), badge, 10, DIM)
    if canvas.interactive and canvas.hit(rect):
        if canvas.ctx.is_mouse_button_clicked(0):
            app.drag_source = dict(material=identifier, slot=slot, origin=canvas.mouse)
        # 位移阈值区分点击与拖放，避免选材料时误改快捷栏
        moved = app.drag_source and math.dist(canvas.mouse, app.drag_source["origin"]) > 5
        if not canvas.ctx.is_mouse_button_down(0) and moved and slot >= 0:
            # 松手帧直接处理落点，避免快速拖放跳过持续拖动状态
            app.assign_hotbar(slot, app.drag_source["material"])

