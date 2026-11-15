"""模式选择页面。"""


class ModeView:
    def __init__(self, app):
        self.app = app
        

    def render(self, canvas):
        app = self.app


        canvas.text(
            (24, 100, canvas.width - 48, 60),
            "模式",
            30,
            "ffffff",
            1,
            app.pixel_font,
        )

        canvas.button(
            (24, 24, 120, 45),
            "返回主页",
            app.show_title_page,
            dark=True,
            font=app.pixel_font,
            identifier="mode-back",
        )

