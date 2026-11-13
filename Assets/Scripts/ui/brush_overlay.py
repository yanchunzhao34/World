"""原笔刷半径、形状及 Shift 直线预览。"""


# 绘制当前笔刷的形状与半径预览。
def draw_brush(canvas, app):
    x, y = canvas.mouse
    radius = app.radius * app.current.get("zoom", 3) / canvas.scale

    if app.shape == 0:
        canvas.ctx.draw_circle(
            canvas.x + x * canvas.scale,
            canvas.y + y * canvas.scale,
            radius * canvas.scale,
            1,
            1,
            1,
            0.8,
            thickness=1.0,
        )

    else:
        canvas.ctx.draw_rect(
            *canvas.bounds((x - radius, y - radius, radius * 2, radius * 2)),
            1,
            1,
            1,
            0.8,
            thickness=1.0,
        )

    if app.drawing and app.straight:
        ox, oy = app.origin

        canvas.ctx.draw_line(
            canvas.x + ox,
            canvas.y + oy,
            canvas.x + x * canvas.scale,
            canvas.y + y * canvas.scale,
            1,
            1,
            1,
            0.8,
            thickness=1,
        )
