"""只显示匹配当前位置、请求号和时效的真实 GPU 探针。"""

import math


def draw_probe(canvas, app, now):
    sample = app.probe_sample
    if not sample.get("valid") or now - app.probe_received > .5:
        return
    state = app.current
    point = tuple(v * canvas.scale for v in canvas.mouse)
    center, camera, zoom = state["camera_center"], state["camera_size"], state["zoom"]
    cell = tuple(math.floor(center[i] + (point[i] - camera[i] / 2) / zoom) for i in range(2))
    if cell != (sample["x"], sample["y"]):
        return
    material = app.data["materials"][sample["material"]]
    x = min(canvas.width - 154, canvas.mouse[0] + 18)
    y = min(canvas.height - 64, canvas.mouse[1] + 20)
    canvas.rect((x, y, 146, 54), "17171cf0", 10)
    canvas.icon((x + 10, y + 12, 28, 28), material["key"])
    canvas.text((x + 46, y + 6, 96, 22), material["zh"], 13, "ffffff")
    canvas.text((x + 46, y + 29, 96, 18), f'{sample["temp"]:.1f} °C', 12, "d5d5dd")
