import Toybox.Lang;
import Toybox.Graphics;
import Toybox.System;

// Ported from prototype/index.html's drawGear and gearText (variant B: AM/PM below the Gear).
module Gear {
    const CENTER_Y = Constants.CY - 36;
    const AMPM_GAP = 9;

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

    function draw(
        dc as Graphics.Dc,
        gearFont as Graphics.FontDefinition,
        smallFont as Graphics.FontDefinition
    ) as Void {
        var hour = System.getClockTime().hour;
        var is24Hour = System.getDeviceSettings().is24Hour;
        var text = gearText(hour, is24Hour);

        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
        dc.drawText(Constants.CX, CENTER_Y, gearFont, text, Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER);

        if (is24Hour) {
            return;
        }

        var ampm = isAM(hour) ? "AM" : "PM";
        var capHeight = dc.getFontHeight(gearFont);
        dc.setColor(Graphics.COLOR_LT_GRAY, Graphics.COLOR_TRANSPARENT);
        dc.drawText(
            Constants.CX,
            CENTER_Y + capHeight / 2 + AMPM_GAP,
            smallFont,
            ampm,
            Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER
        );
    }
}
