"""图鉴显示、发现进度、类型与发现状态过滤。"""

import math

from .discovery_codex import KINDS
from .workshop_style import DIM, ACCENT


class CodexView:
    def __init__(self, app):
        self.app = app
        self.kind, self.filter, self.query, self.scroll = -1, "all", "", 0

    def render(self, c):
        app = self.app
        width, height = min(1120, c.width - 48), min(800, c.height - 48)
        x, y = (c.width - width) / 2, (c.height - height) / 2
        c.rect((x, y, width, height), "ffffff", 20)
        c.regions.append((x, y, width, height))
        c.text((x + 20, y + 14, width - 80, 40), "反应图鉴", 22, font=app.bold_font)
        c.button((x + width - 56, y + 16, 36, 36), "×", app.close_modal)
        found = app.codex.count_found()
        c.text((x + 20, y + 74, 140, 42), f"{found} / {len(app.codex.entries)}", 26)
        c.rect((x + 160, y + 91, 240, 6), "e7e7ec", 3)
        c.rect((x + 160, y + 91, 240 * found / 100, 6), ACCENT, 3)
        c.text((x + 420, y + 74, width - 450, 42), "看过的反应和相变都记在这里", 13, DIM)
        for kind, name in enumerate(KINDS):
            entries = [e for e in app.codex.entries if e["kind"] == kind]
            box_width = (width - 40 - 5 * 12) / 6
            bx = x + 20 + kind * (box_width + 12)
            c.button((bx, y + 128, box_width, 54), "", lambda kind=kind: self.set_kind(kind),
                     active=self.kind == kind, identifier="codex-kind-" + str(kind))
            c.text((bx + 12, y + 132, box_width - 24, 24),
                   f"{name}   {app.codex.count_found(entries)}/{len(entries)}", 12)
            c.rect((bx + 12, y + 166, box_width - 24, 5), "e7e7ec", 2)
            c.rect((bx + 12, y + 166, (box_width - 24) * app.codex.count_found(entries) / max(1, len(entries)), 5), ACCENT, 2)
        for index, (key, label) in enumerate((("all", "全部 100"), ("found", f"已发现 {found}"), ("locked", f"未发现 {100 - found}"))):
            c.button((x + 20 + index * 98, y + 198, 94, 38), label,
                     lambda key=key: self.set_filter(key), active=self.filter == key)
        c.search((x + width - 300, y + 198, 280, 38), self.query, "⌕ 按物质找，比如：铁", "codex-search")
        entries = [entry for entry in app.codex.entries if self.matches(entry)]
        entries.sort(key=lambda e: e["id"] not in app.codex.found)
        clip = x + 20, y + 254, width - 40, height - 274
        columns = 3 if width >= 900 else 2
        card_width = (clip[2] - (columns - 1) * 12) / columns
        content_height = math.ceil(len(entries) / columns) * 160
        maximum = max(0, content_height - clip[3])
        self.scroll = max(0, min(self.scroll, maximum))
        if c.hit(clip):
            self.scroll = max(0, min(maximum, self.scroll - c.ctx.get_mouse_wheel_delta() * 56))
        c.clip(clip)
        for index, entry in enumerate(entries):
            bx = clip[0] + index % columns * (card_width + 12)
            by = clip[1] + index // columns * 160 - self.scroll
            if by + 148 < clip[1] or by > clip[1] + clip[3]:
                continue
            discovered = entry["id"] in app.codex.found
            c.rect((bx, by, card_width, 148), "ffffff", 14, "e3e3e8")
            c.text((bx + 14, by + 10, card_width - 28, 22), KINDS[entry["kind"]], 12, DIM)
            c.text((bx + 14, by + 36, card_width - 28, 28),
                   app.codex.title(entry) if discovered else app.codex.hint(entry), 17)
            ids = entry["inputs"] + (entry["outputs"] if discovered else [])
            for icon_index, identifier in enumerate(ids):
                if identifier >= 0:
                    c.icon((bx + 14 + icon_index * 38, by + 72, 32, 32), app.data["materials"][identifier]["key"])
            c.text((bx + 14, by + 112, card_width - 28, 30),
                   app.codex.description(entry) if discovered else "还没发现 · 试着做一个实验", 12, DIM, wrap=True)
        c.unclip()

    def set_kind(self, kind):
        self.kind, self.scroll = (-1 if self.kind == kind else kind), 0

    def set_filter(self, key):
        self.filter, self.scroll = key, 0

    def matches(self, entry):
        if self.kind >= 0 and entry["kind"] != self.kind:
            return False
        if self.filter != "all" and (entry["id"] in self.app.codex.found) != (self.filter == "found"):
            return False
        query = self.query.strip().lower()
        if not query:
            return True
        return any(query in (self.app.data["materials"][identifier]["zh"] + " "
            + self.app.data["materials"][identifier]["key"] + " "
            + self.app.english_names.get(self.app.data["materials"][identifier]["key"], "")).lower()
            for identifier in entry["inputs"] + entry["outputs"] if identifier >= 0)
