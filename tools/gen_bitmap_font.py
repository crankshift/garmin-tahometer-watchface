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

The AMOLED watches (docs/specs/multi-device.md "AMOLED, awake" and "AMOLED, always-on") differ in three
ways, at their five resolutions (360 to 466 px):

- Their fonts are anti-aliased (`antialias="true"` in fonts.xml). The MIP watches keep 1-bit fonts, so
  their 260 px face stays pixel-identical to v1.
- They get two more Gear fonts, `gear_glow` and `gear_outline`. `gear_glow` is the Gear's digits with
  a Gaussian blur baked in, in three brightness bands, which the face draws under the Gear as a soft
  glow. `gear_outline` is the digits as an outline only, for the always-on view.
- The code refers to both new fonts by resource id on every watch, so resources/fonts/ also holds a tiny
  stand-in for each. The MIP watches never load them, and an AMOLED resolution's own set replaces them.

Usage: tools/gen_bitmap_font.py
Requires: Pillow (pip install Pillow).
"""

import math
import os
from collections import namedtuple

from PIL import Image, ImageDraw, ImageFilter, ImageFont

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
MIP_RESOLUTIONS = [240, 260, 280]
AMOLED_RESOLUTIONS = [360, 390, 416, 454, 466]
RESOLUTIONS = MIP_RESOLUTIONS + AMOLED_RESOLUTIONS

# How a font is drawn: PLAIN is the glyphs as they are, GLOW blurs them, OUTLINE keeps only their outline.
PLAIN, GLOW, OUTLINE = "plain", "glow", "outline"

# A font to generate: its file name, resource id, pixel size on the 260 px screen (Connect IQ bitmap
# fonts don't scale, so this is the size drawn on watch), glyphs, and style.
Font = namedtuple("Font", "name resource_id v1_size glyphs style")

FONTS = [
    Font("gear", "GearFont", 89, DIGITS, PLAIN),
    Font("tachometer_numeral", "TachometerNumeralFont", 24, "0123456", PLAIN),
    Font("slot_value", "SlotValueFont", 20, DIGITS + "-%°:", PLAIN),
    Font("small", "SmallFont", 15, SMALL_LETTERS, PLAIN),
    Font("gear_glow", "GearGlowFont", 89, DIGITS, GLOW),
    Font("gear_outline", "GearOutlineFont", 89, DIGITS, OUTLINE),
]

# The Gear glow's blur, in px on the 260 px screen (scaled like the font sizes), and the outline's width.
# These match the prototype's Gear glow and its always-on Gear.
GLOW_SIGMA_V1 = 7.0
OUTLINE_WIDTH_V1 = 1.3

# An anti-aliased font on Connect IQ has only four coverage levels: none, 1/3, 2/3 and full. The
# resource compiler reads them off a grayscale sheet, cutting at gray 56, 136 and 216 (measured in
# the simulator), and draws the level's share of the font's color. So the anti-aliased sets are
# written with the four levels already picked, at the middle of each range.
LEVEL_GRAYS = [0, 96, 176, 255]

# The glow's three lit levels are picked from the blur, where 1 is the full brightness of the blurred
# digit: the blur is 0.5 at the edge of a stroke and falls off outside it. The prototype draws the
# blurred digit at 45% opacity, so at the edge of a stroke it shows 22% white, and less the further out
# it goes. The face draws the glow in that 22% white (Constants.COLOR_GEAR_GLOW), and the top level
# shows all of it, the middle level two thirds and the bottom level a third. Each threshold below is
# the blur value where the brightness the prototype would show is halfway between two levels.
GLOW_THRESHOLDS = [0.08, 0.24, 0.41]

STAND_IN_GLYPH_PX = 2


def scaled_size(v1_size, px):
    """The pixel size for a screen `px` wide. Halves round up (Python's round() would round 22.5 down)."""
    return math.floor(v1_size * px / V1_PX + 0.5)


def scaled_measure(v1_value, px):
    """A fractional v1 measurement (blur, outline width) on a screen `px` wide."""
    return v1_value * px / V1_PX


def out_dir(px):
    """resources/fonts for the 260 px set, resources-round-{px}x{px}/fonts for the others."""
    if px == V1_PX:
        return os.path.join(ROOT, "resources", "fonts")
    return os.path.join(ROOT, f"resources-round-{px}x{px}", "fonts")


def glyph_bitmap(font, ch, style=PLAIN, px=V1_PX, antialias=False):
    """Render one glyph on a generous transparent canvas and tight-crop it.

    Every glyph is drawn at the same (PAD, PAD) origin with the 'la' (left-ascender) anchor,
    so the crop offset from that shared origin is a true per-glyph yoffset/xoffset relative
    to a common baseline -- no font metrics math needed beyond the ascent/descent used for
    the sheet-wide lineHeight/base below.

    A GLOW or OUTLINE glyph reaches past the plain glyph's box, so its canvas has a margin around the
    origin and its offsets are measured from the origin all the same. The offsets can come out negative.
    A GLOW glyph's yoffset is measured from the top of the taller line box that line_extension gives it.
    """
    ascent, descent = font.getmetrics()
    margin = style_margin(style, px)
    canvas_w = font.size * 2 + margin * 2
    canvas_h = ascent + descent + PAD * 2 + margin * 2
    origin = (PAD + margin, PAD + margin)
    if style == PLAIN:
        img = Image.new("LA", (canvas_w, canvas_h), (0, 0))
        ImageDraw.Draw(img).text(origin, ch, font=font, fill=(255, 255), anchor="la")
        alpha = img.getchannel("A")
    else:
        mask = Image.new("L", (canvas_w, canvas_h), 0)
        draw = ImageDraw.Draw(mask)
        if style == GLOW:
            draw.text(origin, ch, font=font, fill=255, anchor="la")
            alpha = glow_levels(mask.filter(ImageFilter.GaussianBlur(scaled_measure(GLOW_SIGMA_V1, px))))
        else:
            # The ring just outside the glyph: stroke it wider, then knock the glyph itself out.
            draw.text(origin, ch, font=font, fill=0, stroke_width=scaled_measure(OUTLINE_WIDTH_V1, px), stroke_fill=255, anchor="la")
            alpha = mask
    if antialias and style != GLOW:
        alpha = alpha.point([LEVEL_GRAYS[round(3 * v / 255)] for v in range(256)])
    bbox = alpha.getbbox()
    if bbox is None:
        # Whitespace-shaped glyph (shouldn't occur for our glyph sets): keep a 1px stub.
        return Image.new("LA", (1, 1), (0, 0)), 0, 0
    cropped = Image.merge("LA", (Image.new("L", alpha.size, 255), alpha)).crop(bbox)
    xoffset = bbox[0] - origin[0]
    yoffset = bbox[1] - origin[1]
    if style == GLOW:
        # The glow's line box is taller by `line_extension` at the top and the bottom, so that its
        # glyphs start inside it.
        yoffset += line_extension(style, px)
    return cropped, xoffset, yoffset


def glow_levels(blurred):
    """The glow's picture in the anti-aliased font's four gray levels, from a blurred digit."""
    def level(v):
        return sum(v / 255 >= t for t in GLOW_THRESHOLDS)
    return blurred.point([LEVEL_GRAYS[level(v)] for v in range(256)])


def widen_for_glow(glyphs):
    """Make each glow glyph's advance as wide as its halo, so Connect IQ doesn't clip the halo.

    Connect IQ draws a glyph's bitmap only inside the glyph's own advance, from x = 0 to the advance,
    and the glow's halo reaches past the digit on both sides. So every advance grows by `reach`, the
    farthest the halo goes, at each end. The face then draws the glow one digit at a time, each at
    the position of the digit it sits behind, minus reach (Gear.drawGlow).
    """
    reach = max(max(-g["xoffset"], g["xoffset"] + g["bitmap"].width - g["xadvance"], 0) for g in glyphs)
    for g in glyphs:
        g["xoffset"] += reach
        g["xadvance"] += 2 * reach


def clip_to_advance(glyphs):
    """Cut a glyph's bitmap to its advance, which is all Connect IQ would draw of it in any case."""
    for g in glyphs:
        bmp = g["bitmap"]
        left = max(-g["xoffset"], 0)
        right = min(bmp.width, g["xadvance"] - g["xoffset"])
        if left > 0 or right < bmp.width:
            g["bitmap"] = bmp.crop((left, 0, right, bmp.height))
            g["xoffset"] += left


def style_margin(style, px):
    """Canvas margin around a glyph, in px: enough for the blur's tail or the outline's width."""
    if style == GLOW:
        return math.ceil(3 * scaled_measure(GLOW_SIGMA_V1, px))
    if style == OUTLINE:
        return math.ceil(scaled_measure(OUTLINE_WIDTH_V1, px)) + 1
    return 0


def line_extension(style, px):
    """How much taller than the plain font a font's line box is, at the top and again at the bottom.

    Only the glow needs it: its glyphs reach far past the plain glyphs, and CIQ centers text on the line box, so
    growing it evenly keeps the glow centered on the Gear's digits.
    """
    return style_margin(style, px) + PAD if style == GLOW else 0


def fnt_header(size, line_height, base, sheet_w, sheet_h, png_name, char_count, antialias=False):
    """The info, common, page and chars lines of a .fnt file."""
    channels = " alphaChnl=1 redChnl=0 greenChnl=0 blueChnl=0" if antialias else ""
    return [
        f'info face="{FACE_NAME}" size={size} bold=1 italic=0 charset="" unicode=1 '
        f"stretchH=100 smooth=1 aa=1 padding=0,0,0,0 spacing=1,1 outline=0",
        f"common lineHeight={line_height} base={base} scaleW={sheet_w} scaleH={sheet_h} "
        f"pages=1 packed=0{channels}",
        f'page id=0 file="{png_name}"',
        f"chars count={char_count}",
    ]


def fnt_char(char, x, y, width, height, xoffset, yoffset, xadvance):
    """One glyph's line of a .fnt file."""
    return (
        f"char id={ord(char)}   x={x}    y={y}   width={width}  height={height}  "
        f"xoffset={xoffset}  yoffset={yoffset}  xadvance={xadvance}  page=0  chnl=15"
    )


def build_font(directory, name, size, chars, style=PLAIN, px=V1_PX, antialias=False):
    font = ImageFont.truetype(FONT_PATH, size)
    ascent, descent = font.getmetrics()
    extension = line_extension(style, px)
    line_height = ascent + descent + 2 * extension
    base = ascent + extension
    glyphs = []
    for ch in chars:
        bitmap, xoffset, yoffset = glyph_bitmap(font, ch, style, px, antialias)
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

    if style == GLOW:
        widen_for_glow(glyphs)
    elif style == OUTLINE:
        clip_to_advance(glyphs)

    # Pack left to right in a single row.
    sheet_w = sum(g["bitmap"].width + PAD for g in glyphs) + PAD
    sheet_h = max(g["bitmap"].height for g in glyphs) + PAD * 2
    if antialias:
        # The resource compiler reads an anti-aliased font's coverage from a grayscale sheet, as in the
        # SDK's own sample, and would otherwise round it to 1 bit.
        sheet = Image.new("L", (sheet_w, sheet_h), 0)
    else:
        sheet = Image.new("RGBA", (sheet_w, sheet_h), (255, 255, 255, 0))
    x = PAD
    for g in glyphs:
        bmp = g["bitmap"]
        if antialias:
            sheet.paste(bmp.getchannel("A"), (x, PAD))
        else:
            rgba = Image.new("RGBA", bmp.size, (255, 255, 255, 0))
            rgba.putalpha(bmp.getchannel("A"))
            sheet.paste(rgba, (x, PAD), rgba)
        g["x"] = x
        g["y"] = PAD
        x += bmp.width + PAD

    png_name = f"{name}.png"
    fnt_name = f"{name}.fnt"
    sheet.save(os.path.join(directory, png_name))

    lines = fnt_header(size, line_height, base, sheet_w, sheet_h, png_name, len(glyphs), antialias)
    for g in glyphs:
        w, h = g["bitmap"].size
        lines.append(fnt_char(g["char"], g["x"], g["y"], w, h, g["xoffset"], g["yoffset"], g["xadvance"]))
    with open(os.path.join(directory, fnt_name), "w") as f:
        f.write("\n".join(lines) + "\n")

    png_bytes = os.path.getsize(os.path.join(directory, png_name))
    print(f"  {name}: size {size}, {len(glyphs)} glyphs, sheet {sheet_w}x{sheet_h}, {png_bytes} bytes png")


def build_stand_in(directory, name):
    """A font with one tiny glyph, standing in for an AMOLED-only font on the MIP watches.

    Rez.Fonts ids have to exist on every device, but only AMOLED watches load these two fonts, so the
    MIP watches carry the smallest valid font instead of a real one. The font compiler rejects a glyph
    with no lit pixel, and one with an advance of 1 or less.
    """
    size = STAND_IN_GLYPH_PX
    sheet_w, sheet_h = size + PAD * 2, size + PAD * 2
    sheet = Image.new("RGBA", (sheet_w, sheet_h), (255, 255, 255, 0))
    for dx in range(size):
        for dy in range(size):
            sheet.putpixel((PAD + dx, PAD + dy), (255, 255, 255, 255))
    sheet.save(os.path.join(directory, f"{name}.png"))
    lines = fnt_header(size, size, size, sheet_w, sheet_h, f"{name}.png", 1)
    lines.append(fnt_char("0", PAD, PAD, size, size, 0, 0, size))
    with open(os.path.join(directory, f"{name}.fnt"), "w") as f:
        f.write("\n".join(lines) + "\n")
    print(f"  {name}: stand-in")


def fonts_for(px):
    """The (font, real) pairs a screen `px` wide has in its own folder.

    Every screen gets the plain fonts. The AMOLED screens get the glow and outline fonts for real. The
    260 px folder is the base for every watch, so it holds a stand-in for each; the 240 and 280 px MIP
    folders inherit those.
    """
    result = []
    for font in FONTS:
        if font.style == PLAIN or px in AMOLED_RESOLUTIONS:
            result.append((font, True))
        elif px == V1_PX:
            result.append((font, False))
    return result


def write_fonts_xml(directory, fonts, antialias):
    lines = ['<?xml version="1.0" encoding="UTF-8"?>', "<resources>", "  <fonts>"]
    attribute = ' antialias="true"' if antialias else ""
    for font in fonts:
        lines.append(f'    <font id="{font.resource_id}" filename="{font.name}.fnt"{attribute}/>')
    lines += ["  </fonts>", "</resources>"]
    with open(os.path.join(directory, "fonts.xml"), "w") as f:
        f.write("\n".join(lines) + "\n")


def main():
    for px in RESOLUTIONS:
        directory = out_dir(px)
        os.makedirs(directory, exist_ok=True)
        print(f"{px}x{px}: {os.path.relpath(directory, ROOT)}")
        fonts = fonts_for(px)
        for font, real in fonts:
            if real:
                build_font(directory, font.name, scaled_size(font.v1_size, px), font.glyphs, font.style, px, px in AMOLED_RESOLUTIONS)
            else:
                build_stand_in(directory, font.name)
        write_fonts_xml(directory, [font for font, _ in fonts], px in AMOLED_RESOLUTIONS)


if __name__ == "__main__":
    main()
