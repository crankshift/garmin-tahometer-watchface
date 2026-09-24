import Toybox.Lang;

// The theme colors that aren't already Toybox.Graphics built-in constants. The screen geometry
// lives in Screen.mc.
module Constants {
    // The Redline's unlit background arc (docs/design.md "Look").
    const COLOR_REDLINE_UNLIT = 0x550000;

    // The Redline's ticks and numerals in the AMOLED always-on view, dimmed from red
    // (docs/specs/multi-device.md "AMOLED, always-on").
    const COLOR_REDLINE_ALWAYS_ON = 0xAA0000;

    // The Gear glow's color, about 22% white: the brightness a 45% blurred digit has at the edge of
    // its strokes. The glow font has four coverage levels, and this is the top one
    // (tools/gen_bitmap_font.py explains).
    const COLOR_GEAR_GLOW = 0x383838;
}
