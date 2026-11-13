"""物质库及快捷栏共用按钮，拖放由总协调器处理。"""

import math

from .workshop_style import DIM


# 绘制材料按钮并接入选择与拖放交互。
def material_tile(canvas, app, rect, material, slot=-1):
    x, y, width, height = rect
    identifier = material["id"]

    canvas.button(
        rect,
        "",
        lambda: app.select_material(identifier),
        active=identifier == app.material_id,
        identifier=f"slot-{slot}" if slot >= 0 else f"material-{identifier}",
    )
    canvas.icon((x + (width - 32) / 2, y + 14, 32, 32), material["key"])
    canvas.text((x + 2, y + 48, width - 4, 24), material["zh"], 11, align=0.5)

    if material["key"] in app.hotbar:
        assigned = app.hotbar.index(material["key"])

    else:
        assigned = -1

    if slot >= 0:
        badge = str(slot + 1)

    else:
        if assigned >= 0:
            badge = str(assigned + 1)

        else:
            badge = ""

    canvas.text((x + 6, y + 1, width - 12, 14), badge, 10, DIM)

    if canvas.interactive and canvas.hit(rect):
        if canvas.ctx.is_mouse_button_clicked(0):
            app.drag_source = dict(
                material=identifier,
                slot=slot,
                origin=canvas.mouse,
            )

        # 位移阈值区分点击与拖放，避免选材料时误改快捷栏
        moved = (
            app.drag_source and math.dist(canvas.mouse, app.drag_source["origin"]) > 5
        )

        if not canvas.ctx.is_mouse_button_down(0) and moved and slot >= 0:
            # 松手帧直接处理落点，避免快速拖放跳过持续拖动状态
            app.assign_hotbar(slot, app.drag_source["material"])
