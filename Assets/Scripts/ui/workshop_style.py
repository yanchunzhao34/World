"""共享样式和 Infernux 原生绘制工具，坐标采用原 UI 的逻辑像素。"""

from pathlib import Path

from _infernux_packages.workshop.runtime.library.dependencies import Image


INK = "17171c"
DIM = "6b6b78"
ACCENT = "ff7a1a"
STATES = {"Powder": "粉末", "Liquid": "液体", "Gas": "气体",
          "Energy": "能量", "Solid": "固体", "Special": "特殊"}


def color(value):
    if isinstance(value, tuple):
        return value
    value = value.lstrip("#")
    if len(value) == 6:
        value += "ff"
    return tuple(int(value[i:i + 2], 16) / 255 for i in range(0, 8, 2))


class Images:
    def __init__(self, native, assets):
        self.native, self.assets = native, Path(assets)
        self.names = {}

    def get(self, relative):
        name = "workshop/" + relative
        if name not in self.names:
            path = self.assets / relative
            if path.suffix == ".svg":
                path = path.parent.parent / "vector_raster" / (path.stem + ".png")
            with Image.open(path) as source:
                image = source.convert("RGBA")
            self.native.submit_imgui_texture(name, image.tobytes(), *image.size,
                                            nearest="/icons/" in relative, pinned=True)
            self.names[name] = image.size
        return self.native.get_imgui_texture_id(name)

    def close(self):
        for name in self.names:
            self.native.remove_imgui_texture(name)
        self.names.clear()


class Canvas:
    def __init__(self, ctx, app, x, y, width, height, scale):
        self.ctx, self.app = ctx, app
        self.x, self.y, self.scale = x, y, scale
        self.width, self.height = width / scale, height / scale
        self.mouse = ((ctx.get_mouse_pos_x() - x) / scale,
                      (ctx.get_mouse_pos_y() - y) / scale)
        self.interactive = True
        self.input_enabled = True
        self.regions = []
        self.clips = []

    def bounds(self, rect):
        x, y, w, h = rect
        return (self.x + x * self.scale, self.y + y * self.scale,
                self.x + (x + w) * self.scale, self.y + (y + h) * self.scale)

    def hit(self, rect):
        x, y, w, h = rect
        mx, my = self.mouse
        return (self.input_enabled and x <= mx < x + w and y <= my < y + h
                and all(cx <= mx < cx + cw and cy <= my < cy + ch for cx, cy, cw, ch in self.clips))

    def rect(self, rect, fill="ffffff", radius=0, border=None):
        self.ctx.draw_filled_rect(*self.bounds(rect), *color(fill), rounding=radius * self.scale)
        if border:
            self.ctx.draw_rect(*self.bounds(rect), *color(border), thickness=self.scale,
                               rounding=radius * self.scale)

    def text(self, rect, text, size=13, fill=INK, align=0, font=None, wrap=False):
        self.ctx.draw_text_ex_aligned(*self.bounds(rect), str(text), *color(fill),
            align_x=align, align_y=.5, font_size=size * self.scale,
            wrap_width=rect[2] * self.scale if wrap else 0, clip=True,
            font_path=str(font or self.app.font), line_height=1)

    def image(self, rect, relative, rounding=0, opacity=1):
        identifier = self.app.images.get(relative)
        if identifier:
            self.ctx.draw_image_rect(identifier, *self.bounds(rect), tint_a=opacity,
                                     rounding=rounding * self.scale)

    def icon(self, rect, key):
        self.image(rect, "ui/icons/" + key + ".png")

    def button(self, rect, text, callback=None, active=False, dark=False,
               size=13, identifier=None, fill=None, border=None, font=None):
        self.regions.append(rect)
        self.app.widgets[identifier or text] = rect
        hovered = self.hit(rect)
        background = fill or (INK if dark else "fff1e6" if active else "f4f4f6")
        if hovered and self.interactive:
            background = "2b2b33" if dark else "ffeadb" if active else "e7e7ec"
        self.rect(rect, background, 10, border or (ACCENT if active else None))
        if text:
            self.text(rect, text, size, "ffffff" if dark else INK, .5, font)
        clicked = hovered and self.interactive and self.ctx.is_mouse_button_clicked(0)
        if clicked:
            self.app.focus_text("")
            if callback:
                callback()
        return clicked

    def slider(self, rect, value, minimum, maximum, on_change, identifier):
        self.regions.append(rect)
        self.app.widgets[identifier] = rect
        x, y, w, h = rect
        self.rect((x, y + h / 2 - 3, w, 6), "e5e5eb", 3)
        fraction = min(1, max(0, (value - minimum) / (maximum - minimum)))
        self.rect((x, y + h / 2 - 3, w * fraction, 6), ACCENT, 3)
        self.rect((x + w * fraction - 6, y + h / 2 - 6, 12, 12), "ffffff", 6, "b7b7c0")
        if self.interactive and self.hit(rect) and self.ctx.is_mouse_button_down(0):
            on_change(minimum + min(1, max(0, (self.mouse[0] - x) / w)) * (maximum - minimum))

    def search(self, rect, query, placeholder, identifier):
        self.regions.append(rect)
        self.app.widgets[identifier] = rect
        self.rect(rect, "f1f1f4", 10, ACCENT if self.app.text_focus == identifier else None)
        if self.interactive and self.hit(rect) and self.ctx.is_mouse_button_clicked(0):
            self.app.focus_text(identifier)
        self.text((rect[0] + 12, rect[1], rect[2] - 24, rect[3]), query or placeholder,
                  13, INK if query else DIM)
        if self.app.text_focus == identifier:
            measured = self.ctx.calc_text_size(query, 13 * self.scale, str(self.app.font))[0] / self.scale
            self.rect((rect[0] + 12 + min(measured, rect[2] - 28), rect[1] + 10, 1, rect[3] - 20), INK)

    def clip(self, rect):
        self.clips.append(rect)
        self.ctx.push_draw_list_clip_rect(*self.bounds(rect), True)

    def unclip(self):
        self.ctx.pop_draw_list_clip_rect()
        self.clips.pop()
