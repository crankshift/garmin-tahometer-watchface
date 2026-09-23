import Toybox.Lang;
import Toybox.Graphics;
import Toybox.Math;

// Ported from prototype/index.html's drawTachometer and drawNeedle.
module Tachometer {
    const STYLE_NEEDLE = "needle";
    const STYLE_SWEEP = "sweep";
    const STYLE_SWEEP_TIP = "sweepTip";

    const R_BAND = Constants.R - 6;    // Sweep band and unlit Redline radius
    const BAND_W = 8;
    const R_TICK = Constants.R - 11;   // outer end of the ticks
    const R_NUM = Constants.R - 34;

    const NEEDLE_R0 = Constants.R - 46; // just outside the Rev Bar (R - 50)
    const NEEDLE_R1 = Constants.R - 8;
    const NEEDLE_HALF_WIDTH_BASE = 2.5;
    const NEEDLE_HALF_WIDTH_TIP = 1.0;

    // Pure: true past the Redline threshold. Used for minutes (>= 50) and for scale
    // numerals, where the caller passes n * 10 so 5 and 6 land in the Redline too.
    function isRedline(value as Numeric) as Boolean {
        return value >= 50;
    }

    // Pure: [length, penWidth] of the tick at the given minute, 0-60.
    function tickSpec(minute as Number) as Array<Number> {
        if (minute % 10 == 0) {
            return [12, 3];
        } else if (minute % 5 == 0) {
            return [8, 2];
        }
        return [4, 1];
    }

    function drawTachometer(
        dc as Graphics.Dc,
        minute as Number,
        minuteStyle as String,
        numeralFont as Graphics.FontDefinition
    ) as Void {
        drawUnlitRedline(dc);
        if (!minuteStyle.equals(STYLE_NEEDLE)) {
            drawSweep(dc, minute);
        }
        drawTicks(dc);
        drawNumerals(dc, numeralFont);
        if (minuteStyle.equals(STYLE_SWEEP_TIP)) {
            drawTip(dc, minute);
        }
    }

    function drawUnlitRedline(dc as Graphics.Dc) as Void {
        dc.setPenWidth(BAND_W);
        dc.setColor(Constants.COLOR_REDLINE_UNLIT, Graphics.COLOR_TRANSPARENT);
        dc.drawArc(Constants.CX, Constants.CY, R_BAND, Graphics.ARC_CLOCKWISE, Geometry.minuteDeg(50), Geometry.minuteDeg(60));
    }

    // Nothing is drawn at minute 0.
    function drawSweep(dc as Graphics.Dc, minute as Number) as Void {
        if (minute <= 0) {
            return;
        }
        dc.setPenWidth(BAND_W);
        dc.setColor(Graphics.COLOR_YELLOW, Graphics.COLOR_TRANSPARENT);
        var amberEnd = minute < 50 ? minute : 50;
        dc.drawArc(Constants.CX, Constants.CY, R_BAND, Graphics.ARC_CLOCKWISE, Geometry.minuteDeg(0), Geometry.minuteDeg(amberEnd));
        if (minute > 50) {
            dc.setColor(Graphics.COLOR_RED, Graphics.COLOR_TRANSPARENT);
            dc.drawArc(Constants.CX, Constants.CY, R_BAND, Graphics.ARC_CLOCKWISE, Geometry.minuteDeg(50), Geometry.minuteDeg(minute));
        }
    }

    function drawTicks(dc as Graphics.Dc) as Void {
        for (var i = 0; i <= 60; i += 1) {
            var spec = tickSpec(i);
            var length = spec[0];
            var pen = spec[1];
            var deg = Geometry.minuteDeg(i);
            var outer = Geometry.polar(deg, R_TICK);
            var inner = Geometry.polar(deg, R_TICK - length);
            dc.setColor(isRedline(i) ? Graphics.COLOR_RED : Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
            dc.setPenWidth(pen);
            dc.drawLine(outer[0], outer[1], inner[0], inner[1]);
        }
    }

    function drawNumerals(dc as Graphics.Dc, font as Graphics.FontDefinition) as Void {
        for (var n = 0; n <= 6; n += 1) {
            var pos = Geometry.polar(Geometry.minuteDeg(n * 10), R_NUM);
            dc.setColor(isRedline(n * 10) ? Graphics.COLOR_RED : Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
            dc.drawText(pos[0], pos[1], font, n.toString(), Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER);
        }
    }

    function drawTip(dc as Graphics.Dc, minute as Number) as Void {
        var deg = Geometry.minuteDeg(minute);
        var inner = Geometry.polar(deg, R_TICK - 8);
        var outer = Geometry.polar(deg, Constants.R);
        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
        dc.setPenWidth(3);
        dc.drawLine(inner[0], inner[1], outer[0], outer[1]);
    }

    // A floating needle: starts just outside the Rev Bar and has no hub, so it never
    // crosses the Gear.
    function drawNeedle(dc as Graphics.Dc, minute as Number) as Void {
        var deg = Geometry.minuteDeg(minute);
        var rad = Math.toRadians(deg);
        var ux = Math.cos(rad);
        var uy = -Math.sin(rad);
        var px = -uy;
        var py = ux;
        var bx = Constants.CX + ux * NEEDLE_R0;
        var by = Constants.CY + uy * NEEDLE_R0;
        var tx = Constants.CX + ux * NEEDLE_R1;
        var ty = Constants.CY + uy * NEEDLE_R1;
        dc.setColor(isRedline(minute) ? Graphics.COLOR_RED : Graphics.COLOR_YELLOW, Graphics.COLOR_TRANSPARENT);
        dc.fillPolygon([
            [bx + px * NEEDLE_HALF_WIDTH_BASE, by + py * NEEDLE_HALF_WIDTH_BASE],
            [tx + px * NEEDLE_HALF_WIDTH_TIP, ty + py * NEEDLE_HALF_WIDTH_TIP],
            [tx - px * NEEDLE_HALF_WIDTH_TIP, ty - py * NEEDLE_HALF_WIDTH_TIP],
            [bx - px * NEEDLE_HALF_WIDTH_BASE, by - py * NEEDLE_HALF_WIDTH_BASE]
        ] as Array<Array<Float>>);
    }
}
