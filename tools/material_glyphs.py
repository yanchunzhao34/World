"""按指定的单格像素尺寸生成材料汉字图集，供绘制时将一个字映射到一个世界格。"""

import argparse
import json
import os
from pathlib import Path

from PIL import Image, ImageDraw, ImageFont


# 优先用这里的约定，其余材料取游戏配置里的中文名首字和 colorA。
GLYPH_OVERRIDES = {"air": "", "steam": "汽", "acid": "酸", "rust": "锈"}
COLOR_OVERRIDES = {"sand": "#F2A04B", "water": "#289BFF", "block_grey": "#BBBBBB"}


def material_style(material):
    """返回这个材料在世界格子中显示的单字和颜色。空字符串表示透明。"""
    key = material["key"]
    if key in GLYPH_OVERRIDES:
        glyph = GLYPH_OVERRIDES[key]
    elif key.startswith("block_"):
        glyph = "墙"
    elif key.startswith("toy_"):
        glyph = "积"
    else:
        glyph = material["zh"].strip()[:1] or "物"
    return glyph, COLOR_OVERRIDES.get(key, material["colorA"])


def build_atlas(materials, font_path, cell_pixels):
    """cell_pixels 是单格的像素边长。图集的 16 列 × 16 行容纳 256 个材料编号。"""
    if cell_pixels < 1:
        raise ValueError("单格边长至少为 1 像素")
    slots_per_row = 16
    atlas_size = slots_per_row * cell_pixels
    atlas = Image.new("RGBA", (atlas_size, atlas_size))
    # 先绘制清楚的笔画，再缩进一格，避免小字号舍入时丢掉整个字。
    font = ImageFont.truetype(str(font_path), size=max(32, cell_pixels * 2))

    for material in materials:
        material_id = material["id"]
        if not 0 <= material_id <= 255:
            raise ValueError(f"材料编号超出游戏的 8 位范围：{material_id}")

        glyph, color = material_style(material)
        if not glyph:
            continue

        left, top, right, bottom = font.getbbox(glyph)
        stamp = Image.new("RGBA", (right - left, bottom - top))
        ImageDraw.Draw(stamp).text((-left, -top), glyph, font=font, fill=color)
        stamp.thumbnail((cell_pixels, cell_pixels), Image.Resampling.LANCZOS)
        row, column = divmod(material_id, slots_per_row)
        x = column * cell_pixels + (cell_pixels - stamp.width) // 2
        y = row * cell_pixels + (cell_pixels - stamp.height) // 2
        atlas.paste(stamp, (x, y))

    return atlas


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("output_directory", type=Path, help="存放 material_glyphs.png 的目录")
    parser.add_argument("--cell-pixels", required=True, type=int, help="一格的像素边长，例如 3")
    parser.add_argument(
        "--font", type=Path,
        default=Path(os.environ.get("WINDIR", r"C:\Windows")) / "Fonts/msyh.ttc",
        help="中文字体文件，默认使用微软雅黑",
    )
    args = parser.parse_args()
    if args.cell_pixels < 1:
        parser.error("--cell-pixels 至少为 1")

    project = Path(__file__).resolve().parents[1]
    catalog = project / "Assets/Workshop/original/data/game.json"
    materials = json.loads(catalog.read_text(encoding="utf-8"))["materials"]
    atlas = build_atlas(materials, args.font, args.cell_pixels)
    args.output_directory.mkdir(parents=True, exist_ok=True)
    atlas.save(args.output_directory / "material_glyphs.png")


if __name__ == "__main__":
    main()
