import Toybox.Lang;

// Screen geometry shared by every module, plus the one theme color that isn't already a
// Toybox.Graphics built-in constant.
module Constants {
    const CX = 130.0f;
    const CY = 130.0f;
    const R = 130.0f;

    // The Redline's unlit background arc (docs/design.md "Look").
    const COLOR_REDLINE_UNLIT = 0x550000;
}
