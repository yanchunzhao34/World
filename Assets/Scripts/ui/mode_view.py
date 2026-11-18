"""模式选择页面。"""


class ModeView:
    def __init__(self, app):
        self.app = app

    # 模式页缩略图
    def draw_map_entry(
            self,
            canvas,
            rect,
            key,
            title,
            description,       
            thumbnail,
        ):

        app = self.app
        x,y,width,height = rect
        selected = key == app.selected_map

        canvas.button(
            rect,
            "",
            lambda: app.select_scene(key),
            active = selected,
            dark=True,
            fill="383838" if selected else "282828",
            hover_fill="444444",
            border="ffffff" if selected else "282828",
            rounding=0,
            identifier="map-entry-" + key,
        )


        # 左侧缩略图
        image_size = height - 16

        canvas.image(
            (x + 8, y + 8, image_size, image_size),
            thumbnail,
            rounding=2,
        )

        # 右侧名称与说明
        text_x = x + image_size +24
        text_width = width - image_size - 32

        canvas.text(
            (text_x,y+10,text_width,28),
            title,
            size=20,
            fill="ffffff",
            font=app.pixel_font,
        )

        canvas.text(
            (text_x, y + 42, text_width, height - 50),
            description,
            size=14,
            fill="aaaaaa",
            font=app.pixel_font,
            wrap=True,
        )


        # 双击进入地图
        # if (
        #     canvas.interactive
        #     and canvas.hit(rect)
        #     and canvas.ctx.is_mouse_double_clicked(0)
        # ):
        #     app.select_scene(key)
        #     app.start_game(key)



    # 模式页渲染
    def render(self, canvas):
        app = self.app
        width, height = canvas.width,canvas.height



        canvas.rect(
            (0,0,width,height),
            "202020",
        )

        # 中间内容区域水平居中
        content_width = min(960,width - 64)
        content_x = (width - content_width) / 2

        # 顶部标题
        canvas.text(
            (content_x,24,content_width,40),
            "请选择地图",
            size = 28,
            fill="ffffff",
            align=0.5,
            font=app.pixel_font,
        )

        # 列表区域的上下边界
        list_top = 88
        list_bottom = height - 110

        

        canvas.rect(
        (content_x, list_top, content_width, 2),
        "666666",
        )
        canvas.rect(
        (content_x, list_bottom, content_width, 2),
        "666666",
        )


        self.draw_map_entry(
            canvas=canvas,
            rect=(content_x,list_top + 12,content_width,96),
            key="lab",
            title="实验室",
            description="整洁的实验台，可进行材料实验。",
            thumbnail="original/thumbs/lab.jpg",
        )

        canvas.text(
            (24, 100, canvas.width - 48, 60),
            "模式",
            30,
            "ffffff",
            1,
            app.pixel_font,
        )



        button_height = 44
        button_width = 180
        gap = 10
        buttons_x = (width - button_width * 2 - gap) / 2
        button_y = height - 78



        canvas.button(
            (buttons_x,button_y, button_width, button_height),
            "返回主页",
            app.show_title_page,
            dark=True,
            font=app.pixel_font,
            identifier="mode-back",
        )


        canvas.button(
            (buttons_x + button_width + gap,button_y, button_width,button_height),
            "进入游戏",
            lambda: app.start_game(app.selected_map),
            dark=True,
            font=app.pixel_font,

        )


