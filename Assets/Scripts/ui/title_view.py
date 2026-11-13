"""主页布局、八个场景、三种主页语言与双击启动。"""

import json

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
        width, height = canvas.width, canvas.height

        for row in range(80):
            position = row / 80

            if position < 0.38:
                shade = 0.5 * (1 - position / 0.38)

            else:
                shade = 0.55 * min(1, max(0, (position - 0.58) / 0.42))

            canvas.rect(
                (0, position * height, width, height / 80 + 1),
                (10 / 255, 11 / 255, 16 / 255, shade),
            )

        languages = {"zh": "简体中文", "zh-TW": "繁體中文", "en": "English"}

        canvas.button(
            (width - 220, 16, 116, 40),
            "◎ " + languages[app.home_language] + " ⌄",
            lambda: app.open_modal("language"),
            fill="fffffff2",
            identifier="home-language",
            font=app.pixel_font,
        )
        canvas.button(
            (width - 96, 16, 36, 40),
            "",
            lambda: app.open_modal("settings"),
            fill="fffffff2",
            identifier="home-settings",
        )
        canvas.image((width - 87, 27, 18, 18), "ui/vectors/gear.svg")
        canvas.button(
            (width - 52, 16, 36, 40),
            "",
            app.fullscreen,
            fill="fffffff2",
            identifier="home-fullscreen",
        )
        canvas.image((width - 43, 27, 18, 18), "ui/vectors/full.svg")

        compact = height <= 760
        title_size = min(104, max(44, round(width * 0.065)))

        if app.home_language == "en":
            title_size = min(title_size, round((width - 80) / 11))

        title_y = round(height * (0.13 if compact else 0.19))
        text = self.copy("title")
        measured = (
            canvas.ctx.calc_text_size(
                text, title_size * canvas.scale, str(app.pixel_font)
            )[0]
            / canvas.scale
        )
        icon_size = round(title_size * 1.05)
        total = measured + icon_size + round(title_size * 0.28)

        canvas.icon(((width - total) / 2, title_y, icon_size, icon_size), "flask")
        canvas.text(
            (
                (width - total) / 2 + icon_size + title_size * 0.28,
                title_y,
                measured + 8,
                title_size * 1.05,
            ),
            text,
            title_size,
            "ffffff",
            font=app.pixel_font,
        )

        tag_size = min(56, max(26, round(width * 0.034)))
        tag_y = title_y + title_size * 1.05 + (10 if compact else 14) + 4

        canvas.text(
            (24, tag_y, width - 48, tag_size * 1.1),
            "Simulation is all you need",
            tag_size,
            "ffffff",
            0.5,
            app.latin_bold_font,
        )
        canvas.text(
            (24, tag_y + tag_size * 1.1 + 10, width - 48, 26),
            self.copy("subtitle"),
            17,
            "ffffffeb",
            0.5,
            app.pixel_font,
        )

        panel_width = min(1240, width - 48)
        panel_x = (width - panel_width) / 2
        card_width = (panel_width - 110) / 8
        image_height = (card_width - 10) * (0.5 if compact else 0.625)
        card_height = image_height + 36
        panel_height = 16 + 22 + 12 + card_height + 12 + 50 + 18
        panel_y = height - 24 - panel_height

        canvas.regions.append((panel_x, panel_y, panel_width, panel_height))
        canvas.rect((panel_x, panel_y, panel_width, panel_height), "fffffff2", 18)
        canvas.text(
            (panel_x + 20, panel_y + 16, 100, 22),
            self.copy("pickScene"),
            17,
            font=app.pixel_font,
        )
        canvas.text(
            (panel_x + 102, panel_y + 16, 500, 22),
            self.copy("ttSoloHint"),
            13,
            DIM,
            font=app.pixel_font,
        )

        y = panel_y + 50

        for index, key in enumerate(app.MAPS):
            x = panel_x + 20 + index * (card_width + 10)
            rect = x, y, card_width, card_height

            canvas.button(
                rect,
                "",
                lambda key=key: app.select_scene(key),
                active=key == app.selected_map,
                identifier="scene-" + key,
            )
            canvas.image(
                (x + 5, y + 5, card_width - 10, image_height),
                "original/thumbs/" + key + ".jpg",
                8,
            )
            canvas.text(
                (x + 5, y + image_height + 10, card_width - 10, 22),
                self.copy("map." + key),
                13,
                font=app.pixel_font,
            )

            if (
                canvas.interactive
                and canvas.hit(rect)
                and canvas.ctx.is_mouse_double_clicked(0)
            ):
                app.select_scene(key)
                app.start_game(key)

        footer = y + card_height + 12

        canvas.text(
            (panel_x + 20, footer, panel_width - 330, 50),
            self.copy("map." + app.selected_map)
            + "  ·  "
            + self.copy("mapDesc." + app.selected_map),
            13,
            DIM,
            font=app.pixel_font,
            wrap=True,
        )
        canvas.button(
            (panel_x + panel_width - 288, footer, 132, 50),
            self.copy("playMulti"),
            lambda: app.open_modal("network"),
            fill="ffffff",
            border="d4d4db",
            font=app.pixel_font,
        )
        canvas.button(
            (panel_x + panel_width - 144, footer, 124, 50),
            self.copy("start"),
            lambda: app.start_game(app.selected_map),
            dark=True,
            font=app.pixel_font,
            identifier="start-game",
        )
