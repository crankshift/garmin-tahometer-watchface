#!/usr/bin/env python3
"""Draw the launcher icon at a given size: the amber Sweep arc and the white Tip over a black square.

The 40x40 icon in resources/drawables/ is the one the MIP watches use. AMOLED watches want an icon of 54 to
70 px, and the build scales a 40 px one up, which blurs it, so the AMOLED resolutions use a 70x70 one
(the build scales that down for the watches that want less). The geometry below is written for 40 px and
scaled, and it is drawn at 8 times the size and shrunk for smooth edges.

Usage: tools/gen_launcher_icon.py
Requires: Pillow (pip install Pillow).
"""

import os

from PIL import Image, ImageDraw

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
V1_SIZE = 40
SIZE = 70  # px, the largest icon an AMOLED watch asks for
SUPERSAMPLE = 8

AMBER = (255, 170, 0, 255)
WHITE = (255, 255, 255, 255)
BLACK = (0, 0, 0, 255)

# In 40 px units: the arc's center and outer radius, its thickness, and the angles it spans
# (degrees counter-clockwise from 3 o'clock), then the Tip's ends and width.
ARC_CENTER = (20.5, 20.5)
ARC_OUTER = 17.5
ARC_WIDTH = 4.5
ARC_FROM, ARC_TO = 200, 340  # PIL measures clockwise from 3 o'clock, so this is the top of the circle
TIP_FROM, TIP_TO = (19.8, 6.0), (19.8, 21.0)
TIP_WIDTH = 3.0


def render(size):
    k = size / V1_SIZE * SUPERSAMPLE
    img = Image.new("RGBA", (size * SUPERSAMPLE, size * SUPERSAMPLE), BLACK)
    draw = ImageDraw.Draw(img)
    cx, cy = ARC_CENTER
    r = ARC_OUTER
    draw.arc(
        [(cx - r) * k, (cy - r) * k, (cx + r) * k, (cy + r) * k],
        ARC_FROM, ARC_TO, fill=AMBER, width=round(ARC_WIDTH * k),
    )
    draw.line(
        [(TIP_FROM[0] * k, TIP_FROM[1] * k), (TIP_TO[0] * k, TIP_TO[1] * k)],
        fill=WHITE, width=round(TIP_WIDTH * k),
    )
    return img.resize((size, size), Image.LANCZOS)


def main():
    path = os.path.join(ROOT, "resources", "drawables", f"launcher_icon_{SIZE}.png")
    render(SIZE).save(path)
    print(f"{os.path.relpath(path, ROOT)}: {SIZE}x{SIZE}")


if __name__ == "__main__":
    main()
