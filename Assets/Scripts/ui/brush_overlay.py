"""原笔刷半径、形状及 Shift 直线预览。"""

def draw_brush(canvas, app):
    c = canvas
    x, y = c.mouse
    radius = app.radius * app.current.get("zoom", 3) / c.scale
    if app.shape == 0:
        c.ctx.draw_circle(c.x + x * c.scale, c.y + y * c.scale, radius * c.scale,
                          1, 1, 1, .8, thickness=1.0)
    else:
        c.ctx.draw_rect(*c.bounds((x - radius, y - radius, radius * 2, radius * 2)),
                       1, 1, 1, .8, thickness=1.0)
    if app.drawing and app.straight:
        ox, oy = app.origin
        c.ctx.draw_line(c.x + ox, c.y + oy, c.x + x * c.scale, c.y + y * c.scale,
                       1, 1, 1, .8, thickness=1)
