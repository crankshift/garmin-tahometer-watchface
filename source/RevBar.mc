import Toybox.Lang;
import Toybox.Graphics;

// Ported from prototype/index.html's drawRevBar. One arc segment per second; onUpdate draws
// all elapsed segments at once (awake), onPartialUpdate draws only the newest one (low power).
module RevBar {
    // Written for the 260 px screen and scaled by the screen's radius, once, in fit, so the
    // once-a-second onPartialUpdate only reads fields.
    class Layout {
        var rRev as Float;
        var penWidth as Number;

        function initialize(radius as Float) {
            var s = Screen.scaleFor(radius);
            rRev = radius - 50 * s;
            penWidth = Screen.penWidth(3, s);
        }
    }

    // Starts as the 260 px layout; the view calls fit from onLayout.
    var layout as Layout = new Layout(Screen.V1_RADIUS);

    function fit(radius as Float) as Void {
        layout = new Layout(radius);
    }

    // Pure: red for the last 10 seconds, white otherwise.
    function segmentColor(second as Number) as Graphics.ColorType {
        return second >= 50 ? Graphics.COLOR_RED : Graphics.COLOR_WHITE;
    }

    // Pure: a clip rectangle [x, y, width, height] covering segment `second`'s arc, with a
    // small margin for the pen width and anti-aliasing.
    function segmentClipBounds(second as Number) as Array<Number> {
        var startDeg = Geometry.minuteDeg(second) - 0.6;
        var endDeg = Geometry.minuteDeg(second + 1) + 0.6;
        var p1 = Geometry.polar(startDeg, layout.rRev);
        var p2 = Geometry.polar(endDeg, layout.rRev);
        var pad = layout.penWidth / 2.0 + 1;
        var minX = (p1[0] < p2[0] ? p1[0] : p2[0]) - pad;
        var maxX = (p1[0] > p2[0] ? p1[0] : p2[0]) + pad;
        var minY = (p1[1] < p2[1] ? p1[1] : p2[1]) - pad;
        var maxY = (p1[1] > p2[1] ? p1[1] : p2[1]) + pad;
        return [
            minX.toNumber(),
            minY.toNumber(),
            (maxX - minX).toNumber() + 1,
            (maxY - minY).toNumber() + 1
        ];
    }

    function drawSegment(dc as Graphics.Dc, second as Number) as Void {
        dc.setColor(segmentColor(second), Graphics.COLOR_TRANSPARENT);
        dc.setPenWidth(layout.penWidth);
        dc.drawArc(
            Screen.cx,
            Screen.cy,
            layout.rRev,
            Graphics.ARC_CLOCKWISE,
            Geometry.minuteDeg(second) - 0.6,
            Geometry.minuteDeg(second + 1) + 0.6
        );
    }

    // Full redraw: segments 0 to `second` (second + 1 segments). Used every second while awake.
    function draw(dc as Graphics.Dc, second as Number) as Void {
        for (var i = 0; i <= second; i += 1) {
            drawSegment(dc, i);
        }
    }

    // Partial update: only the newest segment, clipped to its bounding box. Used once a second
    // in low power mode when the "Always-on Rev Bar" setting is on.
    function drawPartial(dc as Graphics.Dc, second as Number) as Void {
        var bounds = segmentClipBounds(second);
        dc.setClip(bounds[0], bounds[1], bounds[2], bounds[3]);
        drawSegment(dc, second);
        dc.clearClip();
    }
}
