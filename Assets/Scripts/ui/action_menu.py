"""场景、演示、语言与操作菜单的共同列表显示。"""

from .workshop_style import DIM


def action_menu(canvas, app, rect, items):
    x, y, width, height = rect
    maximum = max(0, len(items) * 42 - height)
    app.menu_scroll = max(0, min(maximum, app.menu_scroll))
    if canvas.hit(rect):
        app.menu_scroll = max(0, min(maximum, app.menu_scroll - canvas.ctx.get_mouse_wheel_delta() * 42))
    canvas.clip(rect)
    for index, (text, action) in enumerate(items):
        cy = y + index * 42 - app.menu_scroll
        if cy + 38 >= y and cy < y + height:
            canvas.button((x, cy, width, 38), text, action, fill="ffffff00",
                          identifier="menu-" + str(index))
    canvas.unclip()
