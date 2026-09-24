#!/usr/bin/env python3
"""Render glyph subsets of a TrueType font into BMFont bitmap fonts.

No BMFont generator (e.g. Hiero, bmGlyph) was available when this project was set up, so
this script fills that gap. It renders each requested glyph with Pillow, tight-crops it,
packs the glyphs into a single row, and writes an AngelCode BMFont text-format .fnt file
plus the matching .png, in the layout Connect IQ's font resource compiler expects (see
"Creating Custom Fonts" in the Connect IQ docs). Re-running it regenerates identical output
from the source font, so only the source TTF and this script need to be reviewed by hand;
the generated .fnt/.png files are committed alongside for the build to use directly.

The face scales in proportion to the screen (docs/specs/multi-device.md "Scaling"), and Connect
IQ bitmap fonts don't scale, so every font is generated once per supported screen width. The
sizes below are the ones for the 260 px screen, and each resolution gets size * px / 260,
rounded half up. The 260 set goes in resources/fonts/, which every watch without a better match
uses. The other sets go in resources-round-{px}x{px}/fonts/, which the build picks for watches
with that screen.

Usage: tools/gen_bitmap_font.py
Requires: Pillow (pip install Pillow).
"""

import math
import os

from PIL import Image, ImageDraw, ImageFont

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
FONT_PATH = os.path.join(ROOT, "assets", "fonts", "BarlowCondensed-Bold.ttf")
FACE_NAME = "Barlow Condensed Bold"
PAD = 2  # px of transparent margin kept around every glyph, and between glyphs on the sheet

DIGITS = "0123456789"

# Union of the letters used by MON/TUE/WED/THU/FRI/SAT/SUN and AM/PM.
_SMALL_WORDS = ["MON", "TUE", "WED", "THU", "FRI", "SAT", "SUN", "AM", "PM"]
SMALL_LETTERS = "".join(sorted(set("".join(_SMALL_WORDS))))

# The screen width the pixel sizes below are written for, and the widths to generate fonts for.
V1_PX = 260
RESOLUTIONS = [240, 260, 280, 360, 390, 416, 454, 466]

# name, resource id, pixel size on the 260 px screen (Connect IQ bitmap fonts don't scale, so
# this is the size drawn on watch), glyphs.
FONTS = [
    ("gear", "GearFont", 89, DIGITS),
    ("tachometer_numeral", "TachometerNumeralFont", 24, "0123456"),
    ("slot_value", "SlotValueFont", 20, DIGITS + "-%°:"),
    ("small", "SmallFont", 15, SMALL_LETTERS),
]


def scaled_size(v1_size, px):
    """The pixel size for a screen `px` wide. Halves round up (Python's round() would round 22.5 down)."""
    return math.floor(v1_size * px / V1_PX + 0.5)


def out_dir(px):
    """resources/fonts for the 260 px set, resources-round-{px}x{px}/fonts for the others."""
    if px == V1_PX:
        return os.path.join(ROOT, "resources", "fonts")
    return os.path.join(ROOT, f"resources-round-{px}x{px}", "fonts")


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


def build_font(directory, name, size, chars):
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
    sheet.save(os.path.join(directory, png_name))

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
    with open(os.path.join(directory, fnt_name), "w") as f:
        f.write("\n".join(lines) + "\n")

    png_bytes = os.path.getsize(os.path.join(directory, png_name))
    print(f"  {name}: size {size}, {len(glyphs)} glyphs, sheet {sheet_w}x{sheet_h}, {png_bytes} bytes png")


def write_fonts_xml(directory):
    lines = ['<?xml version="1.0" encoding="UTF-8"?>', "<resources>", "  <fonts>"]
    for name, resource_id, _, _ in FONTS:
        lines.append(f'    <font id="{resource_id}" filename="{name}.fnt"/>')
    lines += ["  </fonts>", "</resources>"]
    with open(os.path.join(directory, "fonts.xml"), "w") as f:
        f.write("\n".join(lines) + "\n")


def main():
    for px in RESOLUTIONS:
        directory = out_dir(px)
        os.makedirs(directory, exist_ok=True)
        print(f"{px}x{px}: {os.path.relpath(directory, ROOT)}")
        for name, _, v1_size, chars in FONTS:
            build_font(directory, name, scaled_size(v1_size, px), chars)
        write_fonts_xml(directory)


if __name__ == "__main__":
    main()
