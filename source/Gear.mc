import Toybox.Lang;
import Toybox.Graphics;
import Toybox.System;

// Ported from prototype/index.html's drawGear and gearText (variant B: AM/PM below the Gear).
module Gear {
    // Written for the 260 px screen and scaled by the screen's radius (docs/specs/multi-device.md
    // "Scaling"). Built once in fit.
    class Layout {
        var centerY as Float;
        var ampmGap as Float;

        function initialize(radius as Float) {
            var s = Screen.scaleFor(radius);
            centerY = radius - 36 * s; // round screens: the center is at the radius
            ampmGap = 9 * s;
        }
    }

    // Starts as the 260 px layout; the view calls fit from onLayout.
    var layout as Layout = new Layout(Screen.V1_RADIUS);

    function fit(radius as Float) as Void {
        layout = new Layout(radius);
    }

    // Pure: the Gear's text for an hour 0-23, following the 12/24-hour system setting.
    // 24-hour: 0-23, no leading zero. 12-hour: 1-12, no leading zero.
    function gearText(hour as Number, is24Hour as Boolean) as String {
        if (is24Hour) {
            return hour.toString();
        }
        var h12 = hour % 12;
        if (h12 == 0) {
            h12 = 12;
        }
        return h12.toString();
    }

    // Pure: true before noon.
    function isAM(hour as Number) as Boolean {
        return hour < 12;
    }

    // The Gear in `color`, with AM/PM under it in 12-hour mode. The awake face draws it in white with
    // the Gear font; the always-on view draws it in light grey with the outline font, which has
    // the same metrics, so the AM/PM lands in the same place.
    function draw(
        dc as Graphics.Dc,
        gearFont as Graphics.FontDefinition,
        smallFont as Graphics.FontDefinition,
        color as Graphics.ColorType
    ) as Void {
        var hour = System.getClockTime().hour;
        var is24Hour = System.getDeviceSettings().is24Hour;
        var text = gearText(hour, is24Hour);

        dc.setColor(color, Graphics.COLOR_TRANSPARENT);
        dc.drawText(Screen.cx, layout.centerY, gearFont, text, Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER);

        if (is24Hour) {
            return;
        }

        var ampm = isAM(hour) ? "AM" : "PM";
        var capHeight = dc.getFontHeight(gearFont);
        dc.setColor(Graphics.COLOR_LT_GRAY, Graphics.COLOR_TRANSPARENT);
        dc.drawText(
            Screen.cx,
            layout.centerY + capHeight / 2 + layout.ampmGap,
            smallFont,
            ampm,
            Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER
        );
    }

    // AMOLED only, drawn before the Gear: the Gear's digits again in a font with a blur baked in, so it
    // reads as a soft white glow. Each digit's glow goes where the digit does. Connect IQ only draws a
    // glyph inside its own advance, so each glow glyph is wider than its digit by the halo's reach at
    // both ends (tools/gen_bitmap_font.py), which is where the offset in x comes from.
    function drawGlow(
        dc as Graphics.Dc,
        glowFont as Graphics.FontDefinition,
        gearFont as Graphics.FontDefinition
    ) as Void {
        var text = gearText(System.getClockTime().hour, System.getDeviceSettings().is24Hour);
        var x = Screen.cx - dc.getTextWidthInPixels(text, gearFont) / 2.0;
        dc.setColor(Constants.COLOR_GEAR_GLOW, Graphics.COLOR_TRANSPARENT);
        var digits = text.toCharArray();
        for (var i = 0; i < digits.size(); i += 1) {
            var digit = digits[i].toString();
            var advance = dc.getTextWidthInPixels(digit, gearFont);
            var reach = (dc.getTextWidthInPixels(digit, glowFont) - advance) / 2.0;
            dc.drawText(x - reach, layout.centerY, glowFont, digit, Graphics.TEXT_JUSTIFY_LEFT | Graphics.TEXT_JUSTIFY_VCENTER);
            x += advance;
        }
    }
}
