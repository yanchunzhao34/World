"""主页布局、八个场景、三种主页语言与双击启动。"""

import json


from numpy import identity, size

from .workshop_style import INK, DIM



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

        # 顶部控件从画布右边缘定位，图标在同一行内垂直居中。
        header_y = 16
        header_button_height = 40
        header_icon_size = 18
        header_icon_y = header_y + (header_button_height - header_icon_size) / 2

        language_button_width = 116
        language_right_margin = 104
        language_button_x = canvas_width - language_right_margin - language_button_width
        language_button_rect = (
            language_button_x, header_y, language_button_width, header_button_height
        )

        fullscreen_button_width = 36
        fullscreen_right_margin = 16
        fullscreen_button_x = (
            canvas_width - fullscreen_right_margin - fullscreen_button_width
        )
        fullscreen_button_rect = (
            fullscreen_button_x, header_y, fullscreen_button_width, header_button_height
        )
        fullscreen_icon_x = (
            fullscreen_button_x + (fullscreen_button_width - header_icon_size) / 2
        )
        gear_icon_gap = 17
        gear_icon_x = fullscreen_button_x - gear_icon_gap - header_icon_size

        languages = {"zh": "简体中文", "zh-TW": "繁體中文", "en": "English"}

        canvas.button(
            language_button_rect,
            "" + languages[app.home_language] + "",
            lambda: app.open_modal("language"),
            fill="fffffff2",
            identifier="home-language",
            font=app.pixel_font,
        )

        canvas.image(
            (gear_icon_x, header_icon_y, header_icon_size, header_icon_size),
            "ui/vectors/gear.svg",
        )
        canvas.button(
            fullscreen_button_rect,
            "",
            app.fullscreen,
            fill="fffffff2",
            identifier="home-fullscreen",
        )
        canvas.image(
            (fullscreen_icon_x, header_icon_y, header_icon_size, header_icon_size),
            "ui/vectors/full.svg",
        )

        # 先量标题文字的宽度，再把烧瓶和文字作为一组水平居中。
        title_font_size = min(104, max(44, round(canvas_width * 0.065)))

        if app.home_language == "en":
            english_title_max_size = round((canvas_width - 80) / 11)
            title_font_size = min(title_font_size, english_title_max_size)

        title_y = round(canvas_height * (0.13 if compact_layout else 0.19))
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

        # 保留原场景卡片区域的尺寸，用它的上边缘定位主按钮。
        scene_panel_side_margin = 24
        scene_panel_bottom_margin = 24
        scene_panel_width = min(1240, canvas_width - 2 * scene_panel_side_margin)
        scene_card_count = 8
        scene_card_width = (scene_panel_width - 110) / scene_card_count
        scene_thumbnail_width = scene_card_width - 10
        scene_thumbnail_ratio = 0.5 if compact_layout else 0.625
        scene_thumbnail_height = scene_thumbnail_width * scene_thumbnail_ratio
        scene_card_height = scene_thumbnail_height + 36
        scene_panel_header_height = 50
        scene_panel_footer_height = 80
        scene_panel_height = (
            scene_panel_header_height + scene_card_height + scene_panel_footer_height
        )
        scene_panel_y = canvas_height - scene_panel_bottom_margin - scene_panel_height

        

        # 两个主按钮等宽且居中，从设置按钮向上排开始按钮。
        main_button_width = 260
        main_button_height = 48
        main_button_gap = 8
        # 设置按钮底边到原场景区顶部的间距。
        settings_button_bottom_gap = -100
        main_button_x = (canvas_width - main_button_width) / 2

        # y轴设置
        settings_button_y = (
            scene_panel_y - settings_button_bottom_gap - main_button_height
        )
        start_button_y = settings_button_y - main_button_gap - main_button_height
        exitgame_button_y = start_button_y + main_button_gap + 2 * main_button_height + 8


        start_button_rect = (
            main_button_x, start_button_y, main_button_width, main_button_height
        )

        settings_button_rect = (
            main_button_x, settings_button_y, main_button_width, main_button_height
        )

        exit_game_rect = (
            main_button_x, exitgame_button_y,main_button_width, main_button_height
        )

        canvas.button(  # 开始游戏按钮
            start_button_rect,
            self.copy("start"),
            app.show_mode_page,
            dark=True,
            font=app.pixel_font,
            identifier="start-game",
            rounding=3,
            fill="777777",
            border="222222",
        )

        canvas.button(  # 设置按钮
            settings_button_rect,
            "设置",
            lambda: app.open_modal("settings"),
            dark=True,
            font=app.pixel_font,
            identifier="home-settings",
            rounding=3,
            fill="777777",
            border="222222",
        )

        canvas.button(  # 退出游戏
            exit_game_rect,
            "结束游戏",
            lambda: app.request_exit(),
            dark=True,
            font=app.pixel_font,
            identifier="exit-game",
            rounding=3,
            fill="777777",
            border="222222",
        )
