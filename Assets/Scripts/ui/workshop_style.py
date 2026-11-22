"""共享样式和 Infernux 原生绘制工具，坐标采用原 UI 的逻辑像素。"""

from pathlib import Path

from _infernux_packages.workshop.runtime.library.dependencies import Image


INK = "17171c"
DIM = "6b6b78"
ACCENT = "ff7a1a"
STATES = {
    "Powder": "粉末",
    "Liquid": "液体",
    "Gas": "气体",
    "Energy": "能量",
    "Solid": "固体",
    "Special": "特殊",
}


# 将界面颜色表示转换为归一化分量。
def color(value):
    if isinstance(value, tuple):
        return value

    value = value.lstrip("#")

    if len(value) == 6:
        value += "ff"

    return tuple(int(value[i : i + 2], 16) / 255 for i in range(0, 8, 2))


class Images:
    # 初始化界面图片缓存及资源目录。
    def __init__(self, native, assets):
        self.native, self.assets = native, Path(assets)
        self.names = {}

    # 载入或复用指定界面图片的GPU纹理。
    def get(self, relative):
        texture_name = "workshop/" + relative

        if texture_name not in self.names:
            image_path = self.assets / relative

            if image_path.suffix == ".svg":
                image_path = (
                    image_path.parent.parent
                    / "vector_raster"
                    / (image_path.stem + ".png")
                )

            with Image.open(image_path) as source_image:
                rgba_image = source_image.convert("RGBA")

            # 图标采用最近邻采样，避免像素边缘被插值模糊
            self.native.submit_imgui_texture(
                texture_name,
                rgba_image.tobytes(),
                *rgba_image.size,
                nearest="/icons/" in relative,
                pinned=True,
            )

            self.names[texture_name] = rgba_image.size

        return self.native.get_imgui_texture_id(texture_name)

    # 释放当前界面持有的图片纹理缓存。
    def close(self):
        for name in self.names:
            self.native.remove_imgui_texture(name)

        self.names.clear()


class Canvas:
    # 初始化逻辑坐标、裁剪与命中状态。
    def __init__(self, ctx, app, x, y, width, height, scale):
        self.ctx, self.app = ctx, app
        self.x, self.y, self.scale = x, y, scale

        # 布局与鼠标共用逻辑坐标，保证缩放后绘制与命中对齐
        self.width, self.height = width / scale, height / scale
        self.mouse = (
            (ctx.get_mouse_pos_x() - x) / scale,
            (ctx.get_mouse_pos_y() - y) / scale,
        )
        self.interactive = True
        self.input_enabled = True
        self.regions = []
        self.clips = []

    # 将逻辑矩形转换为原生绘制坐标。
    def bounds(self, rect):
        rect_x, rect_y, rect_width, rect_height = rect

        return (
            self.x + rect_x * self.scale,
            self.y + rect_y * self.scale,
            self.x + (rect_x + rect_width) * self.scale,
            self.y + (rect_y + rect_height) * self.scale,
        )

    # 结合输入状态与裁剪范围检测鼠标命中。
    def hit(self, rect):
        rect_x, rect_y, rect_width, rect_height = rect
        mouse_x, mouse_y = self.mouse

        # 命中判定同步裁剪区域，避免滚出面板的控件响应点击
        return (
            self.input_enabled
            and rect_x <= mouse_x < rect_x + rect_width
            and rect_y <= mouse_y < rect_y + rect_height
            and all(
                clip_x <= mouse_x < clip_x + clip_width
                and clip_y <= mouse_y < clip_y + clip_height
                for clip_x, clip_y, clip_width, clip_height in self.clips
            )
        )

    # 按统一缩放规则绘制填充矩形与边框。
    def rect(self, rect, fill="ffffff", radius=0, border=None):
        self.ctx.draw_filled_rect(
            *self.bounds(rect), *color(fill), rounding=radius * self.scale
        )

        if border:
            self.ctx.draw_rect(
                *self.bounds(rect),
                *color(border),
                thickness=self.scale,
                rounding=radius * self.scale,
            )

    # 使用当前界面字体与裁剪规则绘制文本。
    def text(self, rect, text, size=13, fill=INK, align=0, font=None, wrap=False):
        self.ctx.draw_text_ex_aligned(
            *self.bounds(rect),
            str(text),
            *color(fill),
            align_x=align,
            align_y=0.5,
            font_size=size * self.scale,
            wrap_width=rect[2] * self.scale if wrap else 0,
            clip=True,
            font_path=str(font or self.app.font),
            line_height=1,
        )

    # 按当前缩放规则绘制缓存图片。
    def image(self, rect, relative, rounding=0, opacity=1):
        identifier = self.app.images.get(relative)

        if identifier:
            self.ctx.draw_image_rect(
                identifier,
                *self.bounds(rect),
                tint_a=opacity,
                rounding=rounding * self.scale,
            )

    # 绘制指定材料的像素图标。
    def icon(self, rect, key):
        self.image(rect, "ui/icons/" + key + ".png")

    # 绘制按钮并接入鼠标点击回调。
    def button(
        self,
        rect,   # 输入x，y和宽高
        text,   # 输入展示文本
        callback=None,  # 点击按钮时执行的回调函数
        active=False,   # 激活状态
        dark=False, # 是否深色
        size=13,  # 按钮文本字号
        identifier=None,  # 控件标识，用于记录按钮位置
        fill=None,  # 按钮背景颜色
        border=None,  # 按钮边框颜色
        font=None,  # 按钮文本使用的字体
        rounding=10,  # 按钮圆角半径
        hover_fill=None,  # 鼠标悬停时的背景颜色
    ):
        """
        绘制按钮并处理悬停、点击及回调。
        
        返回按钮本帧是否被点击。
        """
        self.regions.append(rect)

        self.app.widgets[identifier or text] = rect
        hovered = self.hit(rect)

        if fill:
            background = fill

        elif dark:
            background = INK

        elif active:
            background = "fff1e6"

        else:
            background = "f4f4f6"

        if hovered and self.interactive:
            if hover_fill:
                background = hover_fill

            elif dark:
                background = "2b2b33"

            elif active:
                background = "ffeadb"

            else:
                background = "e7e7ec"

        self.rect(rect, background, rounding, border or (ACCENT if active else None))

        if text:
            self.text(rect, text, size, "ffffff" if dark else INK, 0.5, font)

        clicked = hovered and self.interactive and self.ctx.is_mouse_button_clicked(0)

        if clicked:
            self.app.focus_text("")

            if callback:
                callback()

        return clicked

    # 绘制连续值控件并交付滑动结果。
    def slider(self, rect, value, minimum, maximum, on_change, identifier, *, block_style=False):
        self.regions.append(rect)

        self.app.widgets[identifier] = rect
        x, y, w, h = rect

        fraction = min(1, max(0, (value - minimum) / (maximum - minimum)))
        if block_style:
            self.rect((x, y + h / 2 - 3, w, 6), "171c18", border="62665b")
            self.rect((x + 1, y + h / 2 - 2, (w - 2) * fraction, 4), "96ba66")
            self.bevel((x + fraction * (w - 10), y + h / 2 - 8, 10, 16),
                       "c7c7b7", "eef0dc", "727669")
            if self.interactive and self.hit(rect) and self.ctx.is_mouse_button_clicked(0):
                self.app.menu_capture = identifier
            dragging = self.interactive and self.app.menu_capture == identifier
        else:
            self.rect((x, y + h / 2 - 3, w, 6), "e5e5eb", 3)
            self.rect((x, y + h / 2 - 3, w * fraction, 6), ACCENT, 3)
            self.rect((x + w * fraction - 6, y + h / 2 - 6, 12, 12), "ffffff", 6, "b7b7c0")
            dragging = self.interactive and self.hit(rect)
        if dragging and self.ctx.is_mouse_button_down(0):
            on_change(
                minimum + min(1, max(0, (self.mouse[0] - x) / w)) * (maximum - minimum)
            )

    def bevel(self, rect, face, light, shade):
        """直角面板的上、左两边受光，下、右两边背光。"""
        x, y, w, h = rect
        self.rect(rect, "171b18")
        self.rect((x + 1, y + 1, w - 2, h - 2), shade)
        self.rect((x + 1, y + 1, w - 4, h - 4), light)
        self.rect((x + 3, y + 3, w - 6, h - 6), face)

    def menu_button(self, rect, label, callback, identifier, *, primary=False, size=16, enabled=True):
        if not enabled:
            self.regions.append(rect)
            self.bevel(rect, "343833", "484d45", "292d27")
            self.text(rect, label, size, "90968b", 0.5)
            return False
        hovered = self.interactive and self.hit(rect)
        if primary:
            face, light, shade = ("587d3c" if hovered else "436534"), "98b875", "2e4429"
        else:
            face, light, shade = ("697063" if hovered else "51574f"), "91978a", "353b34"
        clicked = self.button(rect, "", identifier=identifier, fill="171b18", rounding=0)
        self.bevel(rect, face, light, shade)
        if hovered:
            self.ctx.draw_rect(*self.bounds(rect), *color("e4edcd"), thickness=self.scale)
        x, y, w, h = rect
        self.text((x + 1, y + 2, w, h), label, size, "252c23", 0.5)
        self.text(rect, label, size, "f7f7eb", 0.5)
        if clicked:
            callback()
        return clicked

    def menu_frame(self, title, icon, max_width, max_height):
        """绘制窗口并返回内容区域；底部留给固定操作栏。"""
        margin = 8 if min(self.width, self.height) < 520 else 24
        w, h = min(max_width, self.width - 2 * margin), min(max_height, self.height - 2 * margin)
        x, y = (self.width - w) // 2, (self.height - h) // 2
        self.rect((0, 0, self.width, self.height), "151914bd")
        self.rect((x + 5, y + 6, w, h), "10130fc9")
        self.bevel((x, y, w, h), "aeafa2", "e2e3d3", "626658")
        self.regions.append((x, y, w, h))
        self.bevel((x + 14, y + 12, 32, 32), "c3c4b7", "737868", "d7dbca")
        self.image((x + 18, y + 16, 24, 24), icon)
        self.text((x + 56, y + 9, w - 70, 38), title, 22, "272d26", font=self.app.bold_font)
        return x + 12, y + 54, w - 24, h - 114

    def menu_scroll(self, rect, offset, content_height, identifier, step):
        """滚轮或右侧滚动条都可浏览内容，返回新的像素偏移。"""
        x, y, w, h = rect
        maximum = max(0, content_height - h)
        if not maximum or h < 2:
            return 0
        if self.interactive and self.hit(rect):
            offset -= self.ctx.get_mouse_wheel_delta() * step
        track = (x + w - 13, y, 13, h)
        thumb_h = min(h - 1, max(18, h * h / content_height))
        travel = h - thumb_h
        offset = min(maximum, max(0, offset))
        thumb_y = y + travel * offset / maximum
        if self.interactive and self.hit(track) and self.ctx.is_mouse_button_clicked(0):
            self.app.menu_capture = identifier
            mouse_y = self.mouse[1]
            self.app.menu_grab = mouse_y - thumb_y if thumb_y <= mouse_y < thumb_y + thumb_h else thumb_h / 2
        if self.interactive and self.app.menu_capture == identifier and self.ctx.is_mouse_button_down(0):
            top = min(travel, max(0, self.mouse[1] - y - self.app.menu_grab))
            offset, thumb_y = maximum * top / travel, y + top
        self.rect(track, "191e19")
        self.rect((track[0] + 2, thumb_y, 9, thumb_h), "929887", border="bdc1af")
        return offset

    # 绘制搜索输入区域并管理文本焦点。
    def search(self, rect, query, placeholder, identifier):
        self.regions.append(rect)

        self.app.widgets[identifier] = rect

        self.rect(
            rect, "f1f1f4", 10, ACCENT if self.app.text_focus == identifier else None
        )

        if self.interactive and self.hit(rect) and self.ctx.is_mouse_button_clicked(0):
            self.app.focus_text(identifier)

        self.text(
            (rect[0] + 12, rect[1], rect[2] - 24, rect[3]),
            query or placeholder,
            13,
            INK if query else DIM,
        )

        if self.app.text_focus == identifier:
            measured = (
                self.ctx.calc_text_size(query, 13 * self.scale, str(self.app.font))[0]
                / self.scale
            )

            self.rect(
                (
                    rect[0] + 12 + min(measured, rect[2] - 28),
                    rect[1] + 10,
                    1,
                    rect[3] - 20,
                ),
                INK,
            )

    # 建立绘制与命中判定共用的裁剪区域。
    def clip(self, rect):
        self.clips.append(rect)
        self.ctx.push_draw_list_clip_rect(*self.bounds(rect), True)

    # 结束最近建立的绘制与命中裁剪区域。
    def unclip(self):
        self.ctx.pop_draw_list_clip_rect()
        self.clips.pop()
