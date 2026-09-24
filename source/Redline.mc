import Toybox.Lang;
import Toybox.Graphics;
import Toybox.Math;

// The Redline's AMOLED gradient (docs/specs/multi-device.md "AMOLED, awake", extra 2), ported from
// the prototype's redlineGradient. The watch has no gradient fill, so each band is drawn as
// half-minute arcs, each in one color. The color depends only on the minute and on whether the arc
// is the lit Sweep or the unlit background, so a Sweep that stops at minute 53 ends in the
// minute-53 color.
module Redline {
    const UNLIT_FROM = 0x220000; // at minute 50
    const UNLIT_TO = 0x770000;   // at minute 60
    const LIT_FROM = 0xAA0000;
    const LIT_TO = 0xFF3300;

    const START_MINUTE = 50;
    const SPAN_MINUTES = 10.0f;
    const STEP = 0.5f;

    // Pure: the color a fraction `t` (0 to 1) of the way from `from` to `to`, blended per channel.
    function lerpColor(from as Number, to as Number, t as Float) as Number {
        var color = 0;
        for (var shift = 16; shift >= 0; shift -= 8) {
            var a = (from >> shift) & 0xFF;
            var b = (to >> shift) & 0xFF;
            color |= Math.round(a + (b - a) * t).toNumber() << shift;
        }
        return color;
    }

    // Pure: the color of the half-minute arc that starts at minute `start` (50 to 59.5), sampled in
    // the middle of the arc.
    function halfMinuteColor(start as Float, lit as Boolean) as Number {
        var t = (start + STEP / 2 - START_MINUTE) / SPAN_MINUTES;
        return lit ? lerpColor(LIT_FROM, LIT_TO, t) : lerpColor(UNLIT_FROM, UNLIT_TO, t);
    }

    // The unlit Redline, minute 50 to 60, on a band of the given radius and pen width.
    function drawUnlit(dc as Graphics.Dc, radius as Float, pen as Number) as Void {
        drawGradient(dc, radius, pen, START_MINUTE, START_MINUTE + SPAN_MINUTES, false);
    }

    // The lit part of the Redline, from minute 50 to the current minute (past 50).
    function drawLit(dc as Graphics.Dc, radius as Float, pen as Number, minute as Number) as Void {
        drawGradient(dc, radius, pen, START_MINUTE, minute, true);
    }

    function drawGradient(
        dc as Graphics.Dc,
        radius as Float,
        pen as Number,
        from as Numeric,
        to as Numeric,
        lit as Boolean
    ) as Void {
        dc.setPenWidth(pen);
        for (var start = from.toFloat(); start < to; start += STEP) {
            var end = start + STEP < to ? start + STEP : to.toFloat();
            dc.setColor(halfMinuteColor(start, lit), Graphics.COLOR_TRANSPARENT);
            // The small overlap on the start side hides the seam between two arcs.
            dc.drawArc(
                Screen.cx,
                Screen.cy,
                radius,
                Graphics.ARC_CLOCKWISE,
                Geometry.minuteDeg(start) + 0.2,
                Geometry.minuteDeg(end)
            );
        }
    }
}
