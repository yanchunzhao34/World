"""创建世界的游戏与世界选项。草稿只在玩家确认后交给模拟。"""

from infernux.engine.ui.theme import ImGuiCol, ImGuiStyleVar

from .workshop_style import color


EXPERIMENT_MODE = "experiment"
EMPTY_WORLD = "void"
MAX_WORLD_NAME_LENGTH = 48
WIDE_PAGE_MARGIN = 28
TABS = (("game", "worldGameTab"), ("world", "worldTypeTab"))


# 管理创建世界的表单，玩家确认后将所选世界交给 WorkshopUI 启动。
class CreateWorldView:
    # 保存所属界面，并初始化表单。
    def __init__(self, app):
        self.app = app
        self.reset()

    # 打开创建页时恢复默认世界名、实验模式和空世界。
    def reset(self):
        self.tab = "game"
        self.world_name = self.app.title.copy("worldDefaultName")
        self.game_mode = EXPERIMENT_MODE
        self.world_type = EMPTY_WORLD
        self.editing_name = False

    # 切换“游戏”和“世界”标签，保留已填写的选项。
    def select_tab(self, tab):
        self.tab = tab
        self.editing_name = False

    # 将表单中的游戏模式设为实验模式。
    def select_experiment_mode(self):
        self.game_mode = EXPERIMENT_MODE

    # 将表单中的世界类型设为空世界。
    def select_empty_world(self):
        self.world_type = EMPTY_WORLD

    # 检查世界名是否有效，以及所选模式和世界类型是否已开放。
    def can_create(self):
        return (
            bool(self.world_name.strip())
            and self.game_mode == EXPERIMENT_MODE
            and self.world_type == EMPTY_WORLD
        )

    # 校验表单，并用玩家填写的名称启动世界。
    def create(self):
        if not self.can_create():
            return
        # 实验结束后返回选图页，避免再次显示已提交的创建表单。
        self.app.menu_page = "mode"
        self.app.start_game(self.world_type, world_name=self.world_name.strip())

    # 绘制世界名输入框，记录输入内容和编辑状态。
    def draw_name_field(self, canvas, rect):
        ctx = canvas.ctx
        canvas.regions.append(rect)
        self.app.widgets["world-name"] = rect
        canvas.rect(rect, "131812", border="c3cbb9" if self.editing_name else "798470")
        if not canvas.interactive:
            canvas.text(rect, self.world_name, 16, "f0f2e9")
            return
        # 使用引擎原生输入框，支持中文输入法、光标移动、选区及剪贴板。
        left, top, right, bottom = canvas.bounds(rect)
        previous_x, previous_y = ctx.get_cursor_pos_x(), ctx.get_cursor_pos_y()
        font_height = ctx.calc_text_size("M")[1]
        vertical_padding = max(0, (bottom - top - 4 - font_height) / 2)
        ctx.set_cursor_screen_pos(left + 2, top + 2)
        ctx.set_next_item_width(right - left - 4)
        ctx.push_style_var_vec2(ImGuiStyleVar.FramePadding, 8 * canvas.scale, vertical_padding)
        ctx.push_style_var_float(ImGuiStyleVar.FrameRounding, 0)
        for state in (ImGuiCol.FrameBg, ImGuiCol.FrameBgHovered, ImGuiCol.FrameBgActive):
            ctx.push_style_color(state, *color("131812"))
        try:
            edited_name = ctx.input_text_with_hint(
                "##workshop-world-name", self.app.title.copy("worldName"), self.world_name, 256
            )
            self.world_name = edited_name[:MAX_WORLD_NAME_LENGTH]
            self.editing_name = ctx.is_item_active()
        finally:
            # 输入框临时改动了 ImGui 样式和光标位置，画后续控件前要恢复。
            ctx.pop_style_color(3)
            ctx.pop_style_var(2)
            ctx.set_cursor_pos_x(previous_x)
            ctx.set_cursor_pos_y(previous_y)

    # 按窗口大小安排顶部标签、中间表单和底部按钮。
    def render(self, canvas):
        width, height = canvas.width, canvas.height
        compact = height < 450
        header_height, footer_height = (44, 50) if compact else (64, 74)
        button_height = 34 if compact else 44
        gap = 6 if compact else 10

        side_margin = 12 if width < 640 else WIDE_PAGE_MARGIN
        form_width = min(544, width - 2 * side_margin)
        form_left = (width - form_width) / 2
        footer_top = height - footer_height

        canvas.rect((0, 0, width, height), "11160ec9")
        self.draw_tabs(canvas, (form_left, 0, form_width, header_height), button_height, gap)
        self.draw_form(canvas, (form_left, header_height, form_width, footer_top - header_height),
                       button_height, gap, compact)
        self.draw_footer(canvas, (form_left, footer_top, form_width, footer_height), button_height, gap)

    # 绘制“游戏”和“世界”标签，并高亮当前标签。
    def draw_tabs(self, canvas, rect, button_height, gap):
        left, top, width, height = rect
        translate = self.app.title.copy
        canvas.rect((0, top, canvas.width, height), "292f28f7")
        canvas.rect((0, top + height - 2, canvas.width, 2), "6a7461")
        if canvas.width >= 900:
            title_rect = (WIDE_PAGE_MARGIN, top, left - WIDE_PAGE_MARGIN - 12, height)
            canvas.text(title_rect, translate("createWorld"), 22, "eff1e5", font=self.app.bold_font)

        tab_width = (width - gap) / 2
        tab_top = top + (height - button_height) / 2
        for index, (tab, label_key) in enumerate(TABS):
            tab_left = left + index * (tab_width + gap)
            # tab=tab 把本轮标签记在回调里，点击时 select_tab 收到的就是这个按钮对应的标签。
            canvas.menu_button(
                (tab_left, tab_top, tab_width, button_height), translate(label_key),
                lambda tab=tab: self.select_tab(tab), "create-tab-" + tab, primary=self.tab == tab,
            )

    # 根据当前标签显示世界名和游戏模式，或显示世界类型。
    def draw_form(self, canvas, rect, button_height, gap, compact):
        left, top, width, height = rect
        translate = self.app.title.copy
        show_name_field = self.tab == "game"

        # 每项按顺序给出标识、文案键和点击动作。没有动作的选项显示为禁用。
        if show_name_field:
            heading, hint = "worldMode", "worldModeHint"
            selected = self.game_mode
            choices = (
                (EXPERIMENT_MODE, "worldExperiment", self.select_experiment_mode),
                ("creative", "worldCreative", None),
                ("survival", "worldSurvival", None),
            )
        else:
            heading, hint = "worldType", "worldTypeHint"
            selected = self.world_type
            choices = (
                (EMPTY_WORLD, "worldVoid", self.select_empty_world),
                ("normal", "worldNormal", None),
            )

        label_height = 22 if compact else 28
        hint_height = 32 if compact else 42
        name_height = label_height + button_height + 2 * gap if show_name_field else 0
        # 矮窗口把所有选项排成一行，其余窗口每个选项占一行。
        rows = 1 if compact else len(choices)
        choices_height = rows * button_height + (rows - 1) * gap
        form_height = name_height + label_height + choices_height + hint_height
        label_top = top + max(4, (height - form_height) / 2)

        if show_name_field:
            canvas.text((left, label_top, width, label_height), translate("worldName"), 15, "f1f3e7")
            self.draw_name_field(canvas, (left, label_top + label_height, width, button_height))
            label_top += name_height

        canvas.text((left, label_top, width, label_height), translate(heading), 15, "f1f3e7")
        choices_top = label_top + label_height
        columns = len(choices) if compact else 1
        choice_width = (width - (columns - 1) * gap) / columns
        for index, (key, label_key, on_select) in enumerate(choices):
            row, column = divmod(index, columns)
            choice_left = left + column * (choice_width + gap)
            choice_top = choices_top + row * (button_height + gap)
            canvas.menu_button(
                (choice_left, choice_top, choice_width, button_height), translate(label_key),
                on_select, "create-" + key, primary=key == selected, enabled=on_select is not None,
                size=14 if compact else 16,
            )
        hint_rect = (left, choices_top + choices_height, width, hint_height)
        canvas.text(hint_rect, translate(hint), 13, "c3cab9", wrap=True)

    # 绘制“创建世界”和“取消”按钮，表单有效时允许创建。
    def draw_footer(self, canvas, rect, button_height, gap):
        left, top, width, height = rect
        translate = self.app.title.copy
        canvas.rect((0, top, canvas.width, height), "292f28f7")
        canvas.rect((0, top, canvas.width, 2), "6a7461")

        button_width = (width - gap) / 2
        button_top = top + (height - button_height) / 2
        create_rect = (left, button_top, button_width, button_height)
        cancel_rect = (left + button_width + gap, button_top, button_width, button_height)
        canvas.menu_button(create_rect, translate("createWorld"), self.create, "create-confirm",
                           primary=True, enabled=self.can_create())
        canvas.menu_button(cancel_rect, translate("worldCancel"), self.app.show_mode_page, "create-cancel")
