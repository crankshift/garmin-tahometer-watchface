import Toybox.Lang;
import Toybox.Graphics;
import Toybox.Math;

// Icons, about 14 px, centered on (x, y), drawn with Dc primitives only. Ported from
// prototype/index.html's icon functions.
module Icons {
    function drawSun(dc as Graphics.Dc, x as Float, y as Float, color as Graphics.ColorType, radius as Float) as Void {
        dc.setColor(color, Graphics.COLOR_TRANSPARENT);
        dc.fillCircle(x, y, radius);
        dc.setPenWidth(1.5);
        for (var i = 0; i < 8; i += 1) {
            var a = i * Math.PI / 4;
            var cos = Math.cos(a);
            var sin = Math.sin(a);
            dc.drawLine(
                x + cos * (radius + 1.6), y + sin * (radius + 1.6),
                x + cos * (radius + 3.8), y + sin * (radius + 3.8)
            );
        }
    }

    function drawPump(dc as Graphics.Dc, x as Float, y as Float, color as Graphics.ColorType) as Void {
        dc.setColor(color, Graphics.COLOR_TRANSPARENT);
        dc.fillRectangle(x - 5, y - 6, 7, 12);
        dc.fillRectangle(x - 6.5, y + 5, 10, 2);
        dc.setColor(Graphics.COLOR_BLACK, Graphics.COLOR_TRANSPARENT);
        dc.fillRectangle(x - 3.5, y - 4.5, 4, 3);
        dc.setColor(color, Graphics.COLOR_TRANSPARENT);
        dc.setPenWidth(1.5);
        dc.drawLine(x + 2, y - 4, x + 4.5, y - 4);
        dc.drawLine(x + 4.5, y - 4, x + 5.5, y - 2);
        dc.drawLine(x + 5.5, y - 2, x + 5.5, y + 3);
        dc.drawLine(x + 5.5, y + 3, x + 2, y + 3);
    }

    function drawBolt(dc as Graphics.Dc, x as Float, y as Float, color as Graphics.ColorType) as Void {
        dc.setColor(color, Graphics.COLOR_TRANSPARENT);
        dc.fillPolygon([
            [x + 2, y - 7], [x - 4, y + 1], [x - 0.5, y + 1],
            [x - 2, y + 7], [x + 4, y - 1], [x + 0.5, y - 1]
        ]);
    }
}
