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

        var needleGlowPen as Number;   // the pen the Needle's glow is three strokes around
        var alwaysOnTickPen as Number;
        var alwaysOnNeedlePen as Number;

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

            needleGlowPen = Screen.penWidth(3, s);
            alwaysOnTickPen = Screen.penWidth(2, s);
            alwaysOnNeedlePen = Screen.penWidth(2, s);
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

    // Pure: the color of a tick or numeral, for a value that isRedline takes. Awake: white, red in the
    // Redline. In the always-on view: light grey, dark red in the Redline.
    function scaleColor(value as Numeric, alwaysOn as Boolean) as Graphics.ColorType {
        if (isRedline(value)) {
            return alwaysOn ? Constants.COLOR_REDLINE_ALWAYS_ON : Graphics.COLOR_RED;
        }
        return alwaysOn ? Graphics.COLOR_LT_GRAY : Graphics.COLOR_WHITE;
    }

    // Pure: the Sweep, Tip glow, Needle and always-on needle are amber, and red in the Redline.
    function minuteColor(minute as Number) as Graphics.ColorType {
        return isRedline(minute) ? Graphics.COLOR_RED : Graphics.COLOR_YELLOW;
    }

    // Pure: where the amber part of a Sweep to `minute` ends. The rest of it is in the Redline.
    function amberEnd(minute as Number) as Number {
        return minute < 50 ? minute : 50;
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
        drawNumerals(dc, numeralFont, false);
        if (minuteStyle == STYLE_SWEEP_TIP) {
            drawTip(dc, minute);
        }
    }

    function drawUnlitRedline(dc as Graphics.Dc) as Void {
        if (Screen.amoled) {
            Redline.drawUnlit(dc, layout.rBand, layout.bandW);
        } else {
            dc.setPenWidth(layout.bandW);
            dc.setColor(Constants.COLOR_REDLINE_UNLIT, Graphics.COLOR_TRANSPARENT);
            dc.drawArc(Screen.cx, Screen.cy, layout.rBand, Graphics.ARC_CLOCKWISE, Geometry.minuteDeg(50), Geometry.minuteDeg(60));
        }
    }

    // Nothing is drawn at minute 0.
    function drawSweep(dc as Graphics.Dc, minute as Number) as Void {
        if (minute <= 0) {
            return;
        }
        dc.setPenWidth(layout.bandW);
        dc.setColor(Graphics.COLOR_YELLOW, Graphics.COLOR_TRANSPARENT);
        dc.drawArc(Screen.cx, Screen.cy, layout.rBand, Graphics.ARC_CLOCKWISE, Geometry.minuteDeg(0), Geometry.minuteDeg(amberEnd(minute)));
        if (minute > 50) {
            if (Screen.amoled) {
                Redline.drawLit(dc, layout.rBand, layout.bandW, minute);
            } else {
                dc.setColor(Graphics.COLOR_RED, Graphics.COLOR_TRANSPARENT);
                dc.drawArc(Screen.cx, Screen.cy, layout.rBand, Graphics.ARC_CLOCKWISE, Geometry.minuteDeg(50), Geometry.minuteDeg(minute));
            }
        }
    }

    function drawTick(dc as Graphics.Dc, minute as Number, length as Float, pen as Number, color as Graphics.ColorType) as Void {
        var deg = Geometry.minuteDeg(minute);
        var outer = Geometry.polar(deg, layout.rTick);
        var inner = Geometry.polar(deg, layout.rTick - length);
        dc.setColor(color, Graphics.COLOR_TRANSPARENT);
        dc.setPenWidth(pen);
        dc.drawLine(outer[0], outer[1], inner[0], inner[1]);
    }

    function drawTicks(dc as Graphics.Dc) as Void {
        for (var i = 0; i <= 60; i += 1) {
            var spec = tickSpec(i);
            drawTick(dc, i, spec[0], spec[1], scaleColor(i, false));
        }
    }

    // `alwaysOn` draws them in the always-on view's colors.
    function drawNumerals(dc as Graphics.Dc, font as Graphics.FontDefinition, alwaysOn as Boolean) as Void {
        for (var n = 0; n <= 6; n += 1) {
            var pos = Geometry.polar(Geometry.minuteDeg(n * 10), layout.rNum);
            dc.setColor(scaleColor(n * 10, alwaysOn), Graphics.COLOR_TRANSPARENT);
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
        dc.setColor(minuteColor(minute), Graphics.COLOR_TRANSPARENT);
        dc.fillPolygon([
            [bx + px * layout.needleHalfWidthBase, by + py * layout.needleHalfWidthBase],
            [tx + px * layout.needleHalfWidthTip, ty + py * layout.needleHalfWidthTip],
            [tx - px * layout.needleHalfWidthTip, ty - py * layout.needleHalfWidthTip],
            [bx - px * layout.needleHalfWidthBase, by - py * layout.needleHalfWidthBase]
        ]);
    }

    // AMOLED only, drawn before the face so the face sits on top: a glow around the Sweep, and around
    // the Tip or the Needle, in amber, or red past minute 50.
    function drawGlow(dc as Graphics.Dc, minute as Number, minuteStyle as Number) as Void {
        if (minuteStyle != STYLE_NEEDLE && minute > 0) {
            Glow.drawArc(dc, layout.rBand, Geometry.minuteDeg(0), Geometry.minuteDeg(amberEnd(minute)), layout.bandW, Graphics.COLOR_YELLOW);
            if (minute > 50) {
                Glow.drawArc(dc, layout.rBand, Geometry.minuteDeg(50), Geometry.minuteDeg(minute), layout.bandW, Graphics.COLOR_RED);
            }
        }
        var color = minuteColor(minute);
        var deg = Geometry.minuteDeg(minute);
        if (minuteStyle == STYLE_SWEEP_TIP) {
            Glow.drawLine(dc, Geometry.polar(deg, layout.tipInnerR), Geometry.polar(deg, Screen.radius), layout.tipPen, color);
        } else if (minuteStyle == STYLE_NEEDLE) {
            Glow.drawLine(dc, Geometry.polar(deg, layout.needleR0), Geometry.polar(deg, layout.needleR1), layout.needleGlowPen, color);
        }
    }

    // The always-on view's part of the Tachometer: the major ticks and their numerals in light
    // grey (dark red in the Redline), and a thin needle for the minute, whatever the Minute Style.
    function drawAlwaysOn(dc as Graphics.Dc, minute as Number, numeralFont as Graphics.FontDefinition) as Void {
        for (var n = 0; n <= 6; n += 1) {
            drawTick(dc, n * 10, layout.majorTickLength, layout.alwaysOnTickPen, scaleColor(n * 10, true));
        }
        drawNumerals(dc, numeralFont, true);

        var deg = Geometry.minuteDeg(minute);
        var base = Geometry.polar(deg, layout.needleR0);
        var tip = Geometry.polar(deg, layout.needleR1);
        dc.setColor(minuteColor(minute), Graphics.COLOR_TRANSPARENT);
        dc.setPenWidth(layout.alwaysOnNeedlePen);
        dc.drawLine(base[0], base[1], tip[0], tip[1]);
    }
}
