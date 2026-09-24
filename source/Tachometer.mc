import Toybox.Lang;
import Toybox.Graphics;
import Toybox.Math;

// Ported from prototype/index.html's drawTachometer and drawNeedle.
module Tachometer {
    // Numeric, not string: Connect IQ's settings resource compiler only allows a
    // settingConfig type="list" on a type="number" property (see docs/tickets/03's
    // "Decisions" for the property/setting type table).
    const STYLE_NEEDLE = 0;
    const STYLE_SWEEP = 1;
    const STYLE_SWEEP_TIP = 2;

    // Every pixel value here is written for the 260 px screen and scaled by the screen's radius
    // (docs/specs/multi-device.md "Scaling"). Built once in fit, so drawing only reads fields.
    class Layout {
        var rBand as Float;            // Sweep band and unlit Redline radius
        var bandW as Number;
        var rTick as Float;            // outer end of the ticks
        var rNum as Float;

        var needleR0 as Float;         // just outside the Rev Bar
        var needleR1 as Float;
        var needleHalfWidthBase as Float;
        var needleHalfWidthTip as Float;

        var tipInnerR as Float;
        var tipPen as Number;

        var majorTickLength as Float;
        var majorTickPen as Number;
        var midTickLength as Float;
        var midTickPen as Number;
        var minorTickLength as Float;
        var minorTickPen as Number;

        function initialize(radius as Float) {
            var s = Screen.scaleFor(radius);
            rBand = radius - 6 * s;
            bandW = Screen.penWidth(8, s);
            rTick = radius - 11 * s;
            rNum = radius - 34 * s;

            needleR0 = radius - 46 * s;
            needleR1 = radius - 8 * s;
            needleHalfWidthBase = 2.5 * s;
            needleHalfWidthTip = 1.0 * s;

            tipInnerR = rTick - 8 * s;
            tipPen = Screen.penWidth(3, s);

            majorTickLength = 12 * s;
            majorTickPen = Screen.penWidth(3, s);
            midTickLength = 8 * s;
            midTickPen = Screen.penWidth(2, s);
            minorTickLength = 4 * s;
            minorTickPen = Screen.penWidth(1, s);
        }
    }

    // Starts as the 260 px layout; the view calls fit from onLayout.
    var layout as Layout = new Layout(Screen.V1_RADIUS);

    function fit(radius as Float) as Void {
        layout = new Layout(radius);
    }

    // Pure: true past the Redline threshold. Used for minutes (>= 50) and for scale
    // numerals, where the caller passes n * 10 so 5 and 6 land in the Redline too.
    function isRedline(value as Numeric) as Boolean {
        return value >= 50;
    }

    // [length, penWidth] of the tick at the given minute, 0-60, from the current layout.
    function tickSpec(minute as Number) as Array<Numeric> {
        if (minute % 10 == 0) {
            return [layout.majorTickLength, layout.majorTickPen];
        } else if (minute % 5 == 0) {
            return [layout.midTickLength, layout.midTickPen];
        }
        return [layout.minorTickLength, layout.minorTickPen];
    }

    function drawTachometer(
        dc as Graphics.Dc,
        minute as Number,
        minuteStyle as Number,
        numeralFont as Graphics.FontDefinition
    ) as Void {
        drawUnlitRedline(dc);
        if (minuteStyle != STYLE_NEEDLE) {
            drawSweep(dc, minute);
        }
        drawTicks(dc);
        drawNumerals(dc, numeralFont);
        if (minuteStyle == STYLE_SWEEP_TIP) {
            drawTip(dc, minute);
        }
    }

    function drawUnlitRedline(dc as Graphics.Dc) as Void {
        dc.setPenWidth(layout.bandW);
        dc.setColor(Constants.COLOR_REDLINE_UNLIT, Graphics.COLOR_TRANSPARENT);
        dc.drawArc(Screen.cx, Screen.cy, layout.rBand, Graphics.ARC_CLOCKWISE, Geometry.minuteDeg(50), Geometry.minuteDeg(60));
    }

    // Nothing is drawn at minute 0.
    function drawSweep(dc as Graphics.Dc, minute as Number) as Void {
        if (minute <= 0) {
            return;
        }
        dc.setPenWidth(layout.bandW);
        dc.setColor(Graphics.COLOR_YELLOW, Graphics.COLOR_TRANSPARENT);
        var amberEnd = minute < 50 ? minute : 50;
        dc.drawArc(Screen.cx, Screen.cy, layout.rBand, Graphics.ARC_CLOCKWISE, Geometry.minuteDeg(0), Geometry.minuteDeg(amberEnd));
        if (minute > 50) {
            dc.setColor(Graphics.COLOR_RED, Graphics.COLOR_TRANSPARENT);
            dc.drawArc(Screen.cx, Screen.cy, layout.rBand, Graphics.ARC_CLOCKWISE, Geometry.minuteDeg(50), Geometry.minuteDeg(minute));
        }
    }

    function drawTicks(dc as Graphics.Dc) as Void {
        for (var i = 0; i <= 60; i += 1) {
            var spec = tickSpec(i);
            var length = spec[0];
            var pen = spec[1];
            var deg = Geometry.minuteDeg(i);
            var outer = Geometry.polar(deg, layout.rTick);
            var inner = Geometry.polar(deg, layout.rTick - length);
            dc.setColor(isRedline(i) ? Graphics.COLOR_RED : Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
            dc.setPenWidth(pen);
            dc.drawLine(outer[0], outer[1], inner[0], inner[1]);
        }
    }

    function drawNumerals(dc as Graphics.Dc, font as Graphics.FontDefinition) as Void {
        for (var n = 0; n <= 6; n += 1) {
            var pos = Geometry.polar(Geometry.minuteDeg(n * 10), layout.rNum);
            dc.setColor(isRedline(n * 10) ? Graphics.COLOR_RED : Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
            dc.drawText(pos[0], pos[1], font, n.toString(), Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER);
        }
    }

    function drawTip(dc as Graphics.Dc, minute as Number) as Void {
        var deg = Geometry.minuteDeg(minute);
        var inner = Geometry.polar(deg, layout.tipInnerR);
        var outer = Geometry.polar(deg, Screen.radius);
        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
        dc.setPenWidth(layout.tipPen);
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
        var bx = Screen.cx + ux * layout.needleR0;
        var by = Screen.cy + uy * layout.needleR0;
        var tx = Screen.cx + ux * layout.needleR1;
        var ty = Screen.cy + uy * layout.needleR1;
        dc.setColor(isRedline(minute) ? Graphics.COLOR_RED : Graphics.COLOR_YELLOW, Graphics.COLOR_TRANSPARENT);
        dc.fillPolygon([
            [bx + px * layout.needleHalfWidthBase, by + py * layout.needleHalfWidthBase],
            [tx + px * layout.needleHalfWidthTip, ty + py * layout.needleHalfWidthTip],
            [tx - px * layout.needleHalfWidthTip, ty - py * layout.needleHalfWidthTip],
            [bx - px * layout.needleHalfWidthBase, by - py * layout.needleHalfWidthBase]
        ]);
    }
}
