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

    function drawHeart(dc as Graphics.Dc, x as Float, y as Float, color as Graphics.ColorType) as Void {
        dc.setColor(color, Graphics.COLOR_TRANSPARENT);
        dc.fillCircle(x - 3.2, y - 2, 3.6);
        dc.fillCircle(x + 3.2, y - 2, 3.6);
        dc.fillPolygon([[x - 6.7, y - 0.8], [x + 6.7, y - 0.8], [x, y + 6.5]]);
    }

    function drawSteps(dc as Graphics.Dc, x as Float, y as Float, color as Graphics.ColorType) as Void {
        dc.setColor(color, Graphics.COLOR_TRANSPARENT);
        dc.fillEllipse(x - 3.5, y - 0.5, 2.5, 4);
        dc.fillCircle(x - 3.5, y + 5.2, 1.7);
        dc.fillEllipse(x + 3.5, y - 3.5, 2.5, 4);
        dc.fillCircle(x + 3.5, y + 2.2, 1.7);
    }

    // level: 0.0 (empty) to 1.0 (full).
    function drawBatteryLevel(dc as Graphics.Dc, x as Float, y as Float, color as Graphics.ColorType, level as Float) as Void {
        dc.setColor(color, Graphics.COLOR_TRANSPARENT);
        dc.setPenWidth(1);
        dc.drawRectangle(x - 6.5, y - 3.5, 12, 7);
        dc.fillRectangle(x + 5.5, y - 1.5, 1.5, 3);
        dc.fillRectangle(x - 5, y - 2, 9 * level, 4);
    }

    function drawCloud(dc as Graphics.Dc, x as Float, y as Float, color as Graphics.ColorType) as Void {
        dc.setColor(color, Graphics.COLOR_TRANSPARENT);
        dc.fillCircle(x - 3.5, y + 1.5, 3.2);
        dc.fillCircle(x + 0.5, y - 1, 4.2);
        dc.fillCircle(x + 4.2, y + 1.8, 2.9);
        dc.fillRectangle(x - 3.5, y + 1.5, 7.7, 3.2);
    }

    // level: 0.0 (empty) to 1.0 (full).
    function drawBodyBattery(dc as Graphics.Dc, x as Float, y as Float, color as Graphics.ColorType, level as Float) as Void {
        dc.setColor(color, Graphics.COLOR_TRANSPARENT);
        dc.setPenWidth(1);
        dc.drawRectangle(x - 3.5, y - 5.5, 7, 12);
        dc.fillRectangle(x - 1.5, y - 7, 3, 1.5);
        var h = 9 * level;
        dc.fillRectangle(x - 2, y + 5 - h, 4, h);
    }

    function drawSunEvent(dc as Graphics.Dc, x as Float, y as Float, color as Graphics.ColorType, rise as Boolean) as Void {
        dc.setColor(color, Graphics.COLOR_TRANSPARENT);
        dc.setClip(x - 8, y - 8, 16, 11);
        dc.fillCircle(x, y + 3, 4.5);
        dc.clearClip();
        dc.setPenWidth(1.5);
        dc.drawLine(x - 7, y + 4, x + 7, y + 4);
        if (rise) {
            dc.fillPolygon([[x, y - 8], [x - 3, y - 4.5], [x + 3, y - 4.5]]);
        } else {
            dc.fillPolygon([[x, y - 4.5], [x - 3, y - 8], [x + 3, y - 8]]);
        }
    }

    function drawBell(dc as Graphics.Dc, x as Float, y as Float, color as Graphics.ColorType) as Void {
        dc.setColor(color, Graphics.COLOR_TRANSPARENT);
        dc.fillCircle(x, y - 6.5, 1.2);
        dc.fillCircle(x, y - 1.5, 4.5);
        dc.fillRectangle(x - 4.5, y - 1.5, 9, 4.5);
        dc.fillPolygon([[x - 4.5, y + 2.5], [x + 4.5, y + 2.5], [x + 6.5, y + 4.5], [x - 6.5, y + 4.5]]);
        dc.fillCircle(x, y + 6, 1.6);
    }

    // Ported from prototype/index.html's WEATHER table. Readouts.weatherIconKind maps the
    // platform's CONDITION_* constants onto these seven kinds.
    const WEATHER_ICON_CLEAR = 0;
    const WEATHER_ICON_PARTLY_CLOUDY = 1;
    const WEATHER_ICON_CLOUDY = 2;
    const WEATHER_ICON_RAIN = 3;
    const WEATHER_ICON_SNOW = 4;
    const WEATHER_ICON_THUNDER = 5;
    const WEATHER_ICON_FOG = 6;

    function drawWeatherIcon(dc as Graphics.Dc, x as Float, y as Float, kind as Number) as Void {
        if (kind == WEATHER_ICON_CLEAR) {
            drawSun(dc, x, y, Graphics.COLOR_YELLOW, 3.6);
        } else if (kind == WEATHER_ICON_PARTLY_CLOUDY) {
            drawSun(dc, x + 2.5, y - 2.5, Graphics.COLOR_YELLOW, 2.8);
            drawCloud(dc, x - 1, y + 1.5, Graphics.COLOR_WHITE);
        } else if (kind == WEATHER_ICON_RAIN) {
            drawCloud(dc, x, y - 3, Graphics.COLOR_LT_GRAY);
            dc.setColor(Graphics.COLOR_BLUE, Graphics.COLOR_TRANSPARENT);
            dc.setPenWidth(1.5);
            dc.drawLine(x - 4, y + 4, x - 5.5, y + 7.5);
            dc.drawLine(x, y + 4, x - 1.5, y + 7.5);
            dc.drawLine(x + 4, y + 4, x + 2.5, y + 7.5);
        } else if (kind == WEATHER_ICON_SNOW) {
            drawCloud(dc, x, y - 3, Graphics.COLOR_LT_GRAY);
            dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
            dc.fillCircle(x - 4, y + 6, 1.2);
            dc.fillCircle(x, y + 6, 1.2);
            dc.fillCircle(x + 4, y + 6, 1.2);
        } else if (kind == WEATHER_ICON_THUNDER) {
            drawCloud(dc, x, y - 3, Graphics.COLOR_LT_GRAY);
            dc.setColor(Graphics.COLOR_YELLOW, Graphics.COLOR_TRANSPARENT);
            dc.fillPolygon([
                [x + 1, y + 1], [x - 2.5, y + 5], [x, y + 5],
                [x - 1, y + 8.5], [x + 2.5, y + 4], [x, y + 4]
            ]);
        } else if (kind == WEATHER_ICON_FOG) {
            dc.setColor(Graphics.COLOR_LT_GRAY, Graphics.COLOR_TRANSPARENT);
            dc.setPenWidth(2);
            dc.drawLine(x - 6, y - 4, x + 6, y - 4);
            dc.drawLine(x - 6, y, x + 6, y);
            dc.drawLine(x - 6, y + 4, x + 6, y + 4);
        } else {
            // WEATHER_ICON_CLOUDY, and the safe default for anything unmapped.
            drawCloud(dc, x, y, Graphics.COLOR_LT_GRAY);
        }
    }
}
