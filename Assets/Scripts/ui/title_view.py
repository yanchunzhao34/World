"""主页标题、语言选择及进入世界列表的入口。"""

import json


class TitleView:
    # 初始化主页文案与点击状态。
    def __init__(self, app):
        self.app = app

        self.strings = json.loads(
            (app.assets / "ui/title_copy.json").read_text("utf-8")
        )

    # 取得当前主页语言对应的文案。
    def copy(self, key):
        return self.strings[self.app.home_language].get(
            key, self.strings["zh"].get(key, key)
        )

    # 绘制主页文案与点击并处理交互。
    def render(self, canvas):
        app = self.app
        canvas_width, canvas_height = canvas.width, canvas.height
        compact_layout = canvas_height <= 760

        # 将上下渐变遮罩拆成等高的横条。
        gradient_row_count = 80
        gradient_row_height = canvas_height / gradient_row_count + 1
        for row in range(gradient_row_count):
            row_fraction = row / gradient_row_count

            if row_fraction < 0.38:
                shade_alpha = 0.5 * (1 - row_fraction / 0.38)

            else:
                shade_alpha = 0.55 * min(1, max(0, (row_fraction - 0.58) / 0.42))

            gradient_row_y = row_fraction * canvas_height
            canvas.rect(
                (0, gradient_row_y, canvas_width, gradient_row_height),
                (10 / 255, 11 / 255, 16 / 255, shade_alpha),
            )

        languages = {"zh": "简体中文", "zh-TW": "繁體中文", "en": "English"}
        header_y = 8 if canvas_height < 440 else 16
        canvas.menu_button((canvas_width - 166, header_y, 108, 34), languages[app.home_language],
                           lambda: app.open_modal("language"), "home-language", size=14)
        fullscreen_rect = (canvas_width - 50, header_y, 34, 34)
        canvas.button(fullscreen_rect, "", app.fullscreen, identifier="home-fullscreen",
                      fill="b7baab", hover_fill="e0e3d2", border="292e28", rounding=0)
        canvas.image((canvas_width - 42, header_y + 8, 18, 18), "ui/vectors/full.svg")

        # 先量标题文字的宽度，再把烧瓶和文字作为一组水平居中。
        title_font_size = min(104, max(44, round(canvas_width * 0.065)))

        if app.home_language == "en":
            english_title_max_size = round((canvas_width - 80) / 11)
            title_font_size = min(title_font_size, english_title_max_size)

        title_y = max(50, round(canvas_height * (0.13 if compact_layout else 0.19)))
        if canvas_height < 440:
            title_font_size = min(36, title_font_size)
        title_text = self.copy("title")
        title_text_width = (
            canvas.ctx.calc_text_size(
                title_text, title_font_size * canvas.scale, str(app.pixel_font)
            )[0]
            / canvas.scale
        )
        title_row_height = title_font_size * 1.05
        title_icon_size = round(title_row_height)
        title_icon_gap = title_font_size * 0.28
        title_group_width = title_text_width + title_icon_size + round(title_icon_gap)
        title_group_x = (canvas_width - title_group_width) / 2
        title_text_x = title_group_x + title_icon_size + title_icon_gap
        title_icon_rect = (title_group_x, title_y, title_icon_size, title_icon_size)
        title_text_rect = (
            title_text_x, title_y, title_text_width + 8, title_row_height
        )

        canvas.icon(title_icon_rect, "flask")
        canvas.text(
            title_text_rect,
            title_text,
            title_font_size,
            "ffffff",
            font=app.pixel_font,
        )

        # 标语和副标题共用文字区域的左右边距。
        text_side_margin = 24
        centered_text_width = canvas_width - 2 * text_side_margin
        slogan_box_height = min(56, max(26, round(canvas_width * 0.034)))
        title_to_slogan_gap = 14 if compact_layout else 18
        slogan_y = title_y + title_row_height + title_to_slogan_gap
        subtitle_y = slogan_y + slogan_box_height * 1.1 + 10
        slogan_rect = (
            text_side_margin, slogan_y, centered_text_width, slogan_box_height
        )
        subtitle_rect = (text_side_margin, subtitle_y, centered_text_width, 26)

        if canvas_height >= 440:
            canvas.text(
                slogan_rect,
                "Simulation is all you need",
                30,
                "ffffff",
                0.5,
                app.latin_bold_font,
            )
            canvas.text(
                subtitle_rect,
                self.copy("subtitle"),
                17,
                "ffffffeb",
                0.5,
                app.pixel_font,
            )

        button_width = min(280, canvas_width - 48)
        button_height = 36 if canvas_height < 440 else 46
        gap = 6 if canvas_height < 440 else 8
        group_height = 3 * button_height + 2 * gap
        button_x = (canvas_width - button_width) / 2
        first_y = min(round(canvas_height * 0.56), canvas_height - 16 - group_height)
        end_label = {"zh": "结束游戏", "zh-TW": "結束遊戲", "en": "Quit Game"}[app.home_language]
        actions = (
            (self.copy("start"), app.show_mode_page, "start-game"),
            (self.copy("settings"), lambda: app.open_modal("settings"), "home-settings"),
            (end_label, app.request_exit, "exit-game"),
        )
        for index, (label, callback, identifier) in enumerate(actions):
            rect = (button_x, first_y + index * (button_height + gap), button_width, button_height)
            canvas.menu_button(rect, label, callback, identifier, primary=index == 0)
