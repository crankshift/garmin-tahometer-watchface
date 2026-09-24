import Toybox.Lang;
import Toybox.Graphics;

// The soft halo behind the Minute Style, the Rev Bar and (through its own bitmap font) the Gear on
// AMOLED watches (docs/specs/multi-device.md "AMOLED, awake", extras 3 to 5). The watch can't blur a
// shape, so an arc or line glows as three wider strokes at low alpha, widest first. This module
// draws those strokes; the shapes to glow are each module's own, in its drawGlow.
//
// Alpha needs Graphics.createColor and Dc.setStroke, which are API 4.0+. The AMOLED watches in
// scope all have them, but the MIP watches on API 3.x don't, so every call is behind a `has` check
// and the view only draws the glow when Screen.amoled is set. A later Dc.setColor replaces the
// stroke set here (checked in the simulator; the SDK says setStroke "takes precedence"), so the
// face that is drawn on top needs no reset.
module Glow {
    const PASSES = 3;

    // Each stroke's alpha, 0 to 255: 0.10, 0.16 and 0.26.
    const ALPHAS = [26, 41, 66] as Array<Number>;

    // Written for the 260 px screen and scaled by the screen's radius (docs/specs/multi-device.md
    // "Scaling"). Built once in fit.
    class Layout {
        // How far each stroke reaches past the shape on both sides, widest first: 5, 3.5 and 2 px at 260 px.
        var reach as Array<Float>;

        function initialize(radius as Float) {
            var s = Screen.scaleFor(radius);
            reach = [5.0 * s, 3.5 * s, 2.0 * s] as Array<Float>;
        }
    }

    // Starts as the 260 px layout; the view calls fit from onLayout.
    var layout as Layout = new Layout(Screen.V1_RADIUS);

    function fit(radius as Float) as Void {
        layout = new Layout(radius);
    }

    // Pure: the pen width of stroke number `pass` (0 is the widest) around a shape drawn with `pen`.
    function passWidth(pen as Numeric, pass as Number) as Float {
        return (pen + 2 * layout.reach[pass]).toFloat();
    }

    // True if this watch can draw the glow.
    function supported(dc as Graphics.Dc) as Boolean {
        return (dc has :setStroke) && (Graphics has :createColor);
    }

    // Pure: the red, green and blue channels (0 to 255) of a 0xRRGGBB color.
    function channels(rgb as Number) as Array<Number> {
        return [(rgb >> 16) & 0xFF, (rgb >> 8) & 0xFF, rgb & 0xFF] as Array<Number>;
    }

    // `rgb` with alpha `alpha` (0 to 255), as the 32-bit color Dc.setStroke takes.
    function alphaColor(alpha as Number, rgb as Number) as Number {
        var c = channels(rgb);
        return Graphics.createColor(alpha, c[0], c[1], c[2]);
    }

    // Glow around an arc that is drawn with `pen`.
    function drawArc(
        dc as Graphics.Dc,
        radius as Float,
        startDeg as Float,
        endDeg as Float,
        pen as Numeric,
        rgb as Number
    ) as Void {
        if (!supported(dc)) {
            return;
        }
        for (var pass = 0; pass < PASSES; pass += 1) {
            dc.setStroke(alphaColor(ALPHAS[pass], rgb));
            dc.setPenWidth(passWidth(pen, pass));
            dc.drawArc(Screen.cx, Screen.cy, radius, Graphics.ARC_CLOCKWISE, startDeg, endDeg);
        }
    }

    // Glow around a line that is drawn with `pen`.
    function drawLine(
        dc as Graphics.Dc,
        p1 as Array<Float>,
        p2 as Array<Float>,
        pen as Numeric,
        rgb as Number
    ) as Void {
        if (!supported(dc)) {
            return;
        }
        for (var pass = 0; pass < PASSES; pass += 1) {
            dc.setStroke(alphaColor(ALPHAS[pass], rgb));
            dc.setPenWidth(passWidth(pen, pass));
            dc.drawLine(p1[0], p1[1], p2[0], p2[1]);
        }
    }
}
