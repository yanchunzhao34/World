"""实验世界选择页，使用随项目提供的地图与预览图。"""


# 管理内置地图的选择和预览，并提供创建世界的入口。
class ModeView:
    # 保存所属界面，并初始化地图列表的滚动位置。
    def __init__(self, app):
        self.app = app
        self.scroll = 0
        self.reveal_selection = True

    # 按方向移动选中项，并让列表滚动到该地图。
    def move_selection(self, direction):
        maps = self.app.MAPS
        current = self.app.selected_map
        index = maps.index(current) if current in maps else 0
        self.app.select_scene(maps[max(0, min(len(maps) - 1, index + direction))])
        self.reveal_selection = True

    # 绘制单张地图的列表项，单击选中，双击进入实验。
    def draw_map_entry(self, canvas, rect, key, title, description, thumbnail):
        app = self.app
        x, y, width, height = rect
        selected = key == app.selected_map
        canvas.button(
            rect, "", lambda: app.select_scene(key), identifier="map-entry-" + key,
            fill="414e39" if selected else "303530",
            border="bacd9d" if selected else "444a42", hover_fill="485240", rounding=0,
        )
        if selected:
            canvas.rect((x + 2, y + 2, 3, height - 4), "a4c77b")
        thumb_h = min(64, height - 10)
        thumb_w = round(thumb_h * 16 / 9)
        thumb_y = y + (height - thumb_h) / 2
        canvas.rect((x + 9, thumb_y - 1, thumb_w + 2, thumb_h + 2), "161a15")
        canvas.image((x + 10, thumb_y, thumb_w, thumb_h), thumbnail)
        text_x = x + thumb_w + 20
        text_w = width - thumb_w - 30
        if description:
            canvas.text((text_x, y + 3, text_w, 23), title, 16, "f1f2e8")
            canvas.text((text_x, y + 25, text_w, height - 29),
                        description, 12, "b4bead", wrap=True)
        else:
            canvas.text((text_x, y, text_w, height), title, 18, "f1f2e8")
        if canvas.interactive and canvas.hit(rect) and canvas.ctx.is_mouse_double_clicked(0):
            app.start_game(key)

    # 绘制地图列表和底部操作栏，空间充足时在右侧显示地图预览。
    def render(self, canvas):
        app = self.app
        width, height = canvas.width, canvas.height
        compact = width < 720 or height < 420
        margin = 12 if compact else min(40, round(width * 0.025))
        header_h = 50 if compact else 72
        footer_h = 56 if compact else 76
        gutter = 8 if compact else 18

        # 页首、内容和操作栏共用游戏视口，主页场景由不透明底色覆盖。
        canvas.rect((0, 0, width, height), "222722")
        canvas.rect((0, 0, width, header_h), "353c34")
        canvas.rect((0, header_h - 3, width, 3), "646e5c")
        icon_size = 30 if compact else 40
        icon_y = (header_h - icon_size) // 2
        canvas.bevel((margin, icon_y, icon_size, icon_size), "b9bdab", "dbe0cd", "707966")
        canvas.icon((margin + 4, icon_y + 4, icon_size - 8, icon_size - 8), "flask")
        title_x = margin + icon_size + 14
        canvas.text((title_x, 0, width - title_x - margin, header_h),
                    app.title.copy("pickScene"), 22 if compact else 28, "f1f3e6", font=app.bold_font)

        x, y = margin, header_h + gutter
        w = width - 2 * margin
        h = height - y - footer_h - gutter
        wide = not compact
        list_w = round(w * 0.37) if wide else w
        canvas.rect((x, y, list_w, h), "20251f", border="666d60")
        list_rect = (x + 5, y + 5, list_w - 10, h - 10)
        list_x, list_y, inner_w, inner_h = list_rect
        row_step = max(54, min(88, int((inner_h + 4) / len(app.MAPS)))) if wide else 68
        content_h = len(app.MAPS) * row_step - 4
        if self.reveal_selection and app.selected_map in app.MAPS:
            top = app.MAPS.index(app.selected_map) * row_step
            self.scroll = min(top, max(self.scroll, top + row_step - 4 - inner_h))
            self.reveal_selection = False
        self.scroll = canvas.menu_scroll(list_rect, self.scroll, content_h, "world-scroll", row_step)
        row_w = inner_w - (17 if content_h > inner_h else 0)
        canvas.clip((list_x, list_y, row_w, inner_h))
        for index, key in enumerate(app.MAPS):
            row_y = list_y + index * row_step - self.scroll
            if row_y + row_step <= list_y or row_y >= list_y + inner_h:
                continue
            title = app.title.copy("map." + key)
            description = "" if wide else app.title.copy("mapDesc." + key)
            self.draw_map_entry(canvas, (list_x, row_y, row_w, row_step - 4), key,
                                title, description, "original/thumbs/" + key + ".jpg")
        canvas.unclip()

        if wide:
            key = app.selected_map
            if key not in app.MAPS:
                key = app.MAPS[0]
            preview_x = x + list_w + gutter
            preview_w = w - list_w - gutter
            image_w = min(preview_w - 4, (h - 100) * 16 / 9)
            image_h = image_w * 9 / 16
            image_x = preview_x + (preview_w - image_w) / 2
            canvas.rect((preview_x, y, preview_w, image_h + 4), "171c17", border="555e50")
            canvas.image((image_x, y + 2, image_w, image_h), "original/thumbs/" + key + ".jpg")
            text_y = y + image_h + 18
            canvas.text((preview_x, text_y, preview_w, 32), app.title.copy("map." + key),
                        24, "f3f3e8", font=app.bold_font)
            canvas.text((preview_x, text_y + 35, preview_w, 44),
                        app.title.copy("mapDesc." + key), 16, "c4c9ba", wrap=True)

        self.draw_footer(canvas, margin, footer_h, compact)

    # 从左到右排列返回主页、创建世界和启动所选地图的按钮。
    def draw_footer(self, canvas, margin, footer_height, compact):
        app = self.app
        footer_top = canvas.height - footer_height
        canvas.rect((0, footer_top, canvas.width, footer_height), "353c34")
        canvas.rect((0, footer_top, canvas.width, 2), "646e5c")

        gap = 8
        content_width = canvas.width - 2 * margin
        button_width = min(216, (content_width - 2 * gap) / 3)
        button_height = 38 if compact else 44
        button_top = footer_top + (footer_height - button_height) // 2
        # 三个按钮共用宽度和纵坐标。左右按钮贴页边距，“创建世界”始终对齐窗口中心。
        back_rect = (margin, button_top, button_width, button_height)
        create_rect = ((canvas.width - button_width) / 2, button_top, button_width, button_height)
        start_rect = (canvas.width - margin - button_width, button_top, button_width, button_height)

        short_labels = button_width < 150
        font_size = 13 if short_labels else 16
        back_label = {"zh": "返回主页", "zh-TW": "返回主頁", "en": "Back"}[app.home_language]
        start_label = app.title.copy("worldPlay" if short_labels else "start")
        canvas.menu_button(back_rect, back_label, app.show_title_page, "mode-back", size=font_size)
        canvas.menu_button(create_rect, app.title.copy("createWorld"), app.show_create_page,
                           "mode-create", size=font_size)
        canvas.menu_button(start_rect, start_label, lambda: app.start_game(app.selected_map),
                           "mode-start", primary=True, size=font_size)
