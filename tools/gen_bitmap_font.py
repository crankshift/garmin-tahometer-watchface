#!/usr/bin/env python3
"""Render glyph subsets of a TrueType font into BMFont bitmap fonts.

No BMFont generator (e.g. Hiero, bmGlyph) was available when this project was set up, so
this script fills that gap. It renders each requested glyph with Pillow, tight-crops it,
packs the glyphs into a single row, and writes an AngelCode BMFont text-format .fnt file
plus the matching .png, in the layout Connect IQ's font resource compiler expects (see
"Creating Custom Fonts" in the Connect IQ docs). Re-running it regenerates identical output
from the source font, so only the source TTF and this script need to be reviewed by hand;
the generated .fnt/.png files are committed alongside for the build to use directly.

Usage: tools/gen_bitmap_font.py
Requires: Pillow (pip install Pillow).
"""

import os

from PIL import Image, ImageDraw, ImageFont

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
FONT_PATH = os.path.join(ROOT, "assets", "fonts", "BarlowCondensed-Bold.ttf")
OUT_DIR = os.path.join(ROOT, "resources", "fonts")
FACE_NAME = "Barlow Condensed Bold"
PAD = 2  # px of transparent margin kept around every glyph, and between glyphs on the sheet

DIGITS = "0123456789"

# Union of the letters used by MON/TUE/WED/THU/FRI/SAT/SUN and AM/PM.
_SMALL_WORDS = ["MON", "TUE", "WED", "THU", "FRI", "SAT", "SUN", "AM", "PM"]
SMALL_LETTERS = "".join(sorted(set("".join(_SMALL_WORDS))))

# name, pixel size (Connect IQ bitmap fonts don't scale, so this is the size drawn on watch),
# glyphs.
FONTS = [
    ("gear", 89, DIGITS),
    ("tachometer_numeral", 24, "0123456"),
    ("slot_value", 20, DIGITS + "-%°:"),
    ("small", 15, SMALL_LETTERS),
]


def glyph_bitmap(font, ch):
    """Render one glyph on a generous transparent canvas and tight-crop it.

    Every glyph is drawn at the same (PAD, PAD) origin with the 'la' (left-ascender) anchor,
    so the crop offset from that shared origin is a true per-glyph yoffset/xoffset relative
    to a common baseline -- no font metrics math needed beyond the ascent/descent used for
    the sheet-wide lineHeight/base below.
    """
    ascent, descent = font.getmetrics()
    canvas_w = font.size * 2
    canvas_h = ascent + descent + PAD * 2
    img = Image.new("LA", (canvas_w, canvas_h), (0, 0))
    draw = ImageDraw.Draw(img)
    draw.text((PAD, PAD), ch, font=font, fill=(255, 255), anchor="la")
    bbox = img.getbbox()
    if bbox is None:
        # Whitespace-shaped glyph (shouldn't occur for our glyph sets): keep a 1px stub.
        return Image.new("LA", (1, 1), (0, 0)), 0, 0
    cropped = img.crop(bbox)
    xoffset = bbox[0] - PAD
    yoffset = bbox[1] - PAD
    return cropped, xoffset, yoffset


def build_font(name, size, chars):
    font = ImageFont.truetype(FONT_PATH, size)
    ascent, descent = font.getmetrics()
    line_height = ascent + descent
    glyphs = []
    for ch in chars:
        bitmap, xoffset, yoffset = glyph_bitmap(font, ch)
        xadvance = round(font.getlength(ch))
        glyphs.append(
            {
                "char": ch,
                "bitmap": bitmap,
                "xoffset": xoffset,
                "yoffset": yoffset,
                "xadvance": xadvance,
            }
        )

    # Pack left to right in a single row.
    sheet_w = sum(g["bitmap"].width + PAD for g in glyphs) + PAD
    sheet_h = max(g["bitmap"].height for g in glyphs) + PAD * 2
    sheet = Image.new("RGBA", (sheet_w, sheet_h), (255, 255, 255, 0))
    x = PAD
    for g in glyphs:
        bmp = g["bitmap"]
        rgba = Image.new("RGBA", bmp.size, (255, 255, 255, 0))
        rgba.putalpha(bmp.getchannel("A"))
        sheet.paste(rgba, (x, PAD), rgba)
        g["x"] = x
        g["y"] = PAD
        x += bmp.width + PAD

    png_name = f"{name}.png"
    fnt_name = f"{name}.fnt"
    sheet.save(os.path.join(OUT_DIR, png_name))

    lines = []
    lines.append(
        f'info face="{FACE_NAME}" size={size} bold=1 italic=0 charset="" unicode=1 '
        f"stretchH=100 smooth=1 aa=1 padding=0,0,0,0 spacing=1,1 outline=0"
    )
    lines.append(
        f"common lineHeight={line_height} base={ascent} scaleW={sheet_w} scaleH={sheet_h} "
        f"pages=1 packed=0"
    )
    lines.append(f'page id=0 file="{png_name}"')
    lines.append(f"chars count={len(glyphs)}")
    for g in glyphs:
        cid = ord(g["char"])
        w, h = g["bitmap"].size
        lines.append(
            "char id={id}   x={x}    y={y}   width={w}  height={h}  "
            "xoffset={xoffset}  yoffset={yoffset}  xadvance={xadvance}  page=0  chnl=15".format(
                id=cid,
                x=g["x"],
                y=g["y"],
                w=w,
                h=h,
                xoffset=g["xoffset"],
                yoffset=g["yoffset"],
                xadvance=g["xadvance"],
            )
        )
    with open(os.path.join(OUT_DIR, fnt_name), "w") as f:
        f.write("\n".join(lines) + "\n")

    png_bytes = os.path.getsize(os.path.join(OUT_DIR, png_name))
    print(f"{name}: {len(glyphs)} glyphs, sheet {sheet_w}x{sheet_h}, {png_bytes} bytes png")


def main():
    os.makedirs(OUT_DIR, exist_ok=True)
    for name, size, chars in FONTS:
        build_font(name, size, chars)


if __name__ == "__main__":
    main()
