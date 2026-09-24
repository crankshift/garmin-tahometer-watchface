import Toybox.Lang;
import Toybox.Graphics;
import Toybox.Math;

// Icons, about 14 px at 260 px, centered on (x, y), drawn with Dc primitives only. Ported from
// prototype/index.html's icon functions. Every number below is written for the 260 px screen;
// each function multiplies it by Screen.scale (`s`) when it draws.
module Icons {
    // `radius` is the sun's disc radius at 260 px.
    function drawSun(dc as Graphics.Dc, x as Float, y as Float, color as Graphics.ColorType, radius as Float) as Void {
        var s = Screen.scale;
        var r = radius * s;
        dc.setColor(color, Graphics.COLOR_TRANSPARENT);
        dc.fillCircle(x, y, r);
        dc.setPenWidth(Screen.strokeWidth(1.5, s));
        for (var i = 0; i < 8; i += 1) {
            var a = i * Math.PI / 4;
            var cos = Math.cos(a);
            var sin = Math.sin(a);
            dc.drawLine(
                x + cos * (r + 1.6 * s), y + sin * (r + 1.6 * s),
                x + cos * (r + 3.8 * s), y + sin * (r + 3.8 * s)
            );
        }
    }

    function drawPump(dc as Graphics.Dc, x as Float, y as Float, color as Graphics.ColorType) as Void {
        var s = Screen.scale;
        dc.setColor(color, Graphics.COLOR_TRANSPARENT);
        dc.fillRectangle(x - 5 * s, y - 6 * s, 7 * s, 12 * s);
        dc.fillRectangle(x - 6.5 * s, y + 5 * s, 10 * s, 2 * s);
        dc.setColor(Graphics.COLOR_BLACK, Graphics.COLOR_TRANSPARENT);
        dc.fillRectangle(x - 3.5 * s, y - 4.5 * s, 4 * s, 3 * s);
        dc.setColor(color, Graphics.COLOR_TRANSPARENT);
        dc.setPenWidth(Screen.strokeWidth(1.5, s));
        dc.drawLine(x + 2 * s, y - 4 * s, x + 4.5 * s, y - 4 * s);
        dc.drawLine(x + 4.5 * s, y - 4 * s, x + 5.5 * s, y - 2 * s);
        dc.drawLine(x + 5.5 * s, y - 2 * s, x + 5.5 * s, y + 3 * s);
        dc.drawLine(x + 5.5 * s, y + 3 * s, x + 2 * s, y + 3 * s);
    }

    function drawBolt(dc as Graphics.Dc, x as Float, y as Float, color as Graphics.ColorType) as Void {
        var s = Screen.scale;
        dc.setColor(color, Graphics.COLOR_TRANSPARENT);
        dc.fillPolygon([
            [x + 2 * s, y - 7 * s], [x - 4 * s, y + 1 * s], [x - 0.5 * s, y + 1 * s],
            [x - 2 * s, y + 7 * s], [x + 4 * s, y - 1 * s], [x + 0.5 * s, y - 1 * s]
        ]);
    }

    function drawHeart(dc as Graphics.Dc, x as Float, y as Float, color as Graphics.ColorType) as Void {
        var s = Screen.scale;
        dc.setColor(color, Graphics.COLOR_TRANSPARENT);
        dc.fillCircle(x - 3.2 * s, y - 2 * s, 3.6 * s);
        dc.fillCircle(x + 3.2 * s, y - 2 * s, 3.6 * s);
        dc.fillPolygon([[x - 6.7 * s, y - 0.8 * s], [x + 6.7 * s, y - 0.8 * s], [x, y + 6.5 * s]]);
    }

    function drawSteps(dc as Graphics.Dc, x as Float, y as Float, color as Graphics.ColorType) as Void {
        var s = Screen.scale;
        dc.setColor(color, Graphics.COLOR_TRANSPARENT);
        dc.fillEllipse(x - 3.5 * s, y - 0.5 * s, 2.5 * s, 4 * s);
        dc.fillCircle(x - 3.5 * s, y + 5.2 * s, 1.7 * s);
        dc.fillEllipse(x + 3.5 * s, y - 3.5 * s, 2.5 * s, 4 * s);
        dc.fillCircle(x + 3.5 * s, y + 2.2 * s, 1.7 * s);
    }

    // level: 0.0 (empty) to 1.0 (full).
    function drawBatteryLevel(dc as Graphics.Dc, x as Float, y as Float, color as Graphics.ColorType, level as Float) as Void {
        var s = Screen.scale;
        dc.setColor(color, Graphics.COLOR_TRANSPARENT);
        dc.setPenWidth(Screen.strokeWidth(1, s));
        dc.drawRectangle(x - 6.5 * s, y - 3.5 * s, 12 * s, 7 * s);
        dc.fillRectangle(x + 5.5 * s, y - 1.5 * s, 1.5 * s, 3 * s);
        dc.fillRectangle(x - 5 * s, y - 2 * s, 9 * s * level, 4 * s);
    }

    function drawCloud(dc as Graphics.Dc, x as Float, y as Float, color as Graphics.ColorType) as Void {
        var s = Screen.scale;
        dc.setColor(color, Graphics.COLOR_TRANSPARENT);
        dc.fillCircle(x - 3.5 * s, y + 1.5 * s, 3.2 * s);
        dc.fillCircle(x + 0.5 * s, y - 1 * s, 4.2 * s);
        dc.fillCircle(x + 4.2 * s, y + 1.8 * s, 2.9 * s);
        dc.fillRectangle(x - 3.5 * s, y + 1.5 * s, 7.7 * s, 3.2 * s);
    }

    // level: 0.0 (empty) to 1.0 (full).
    function drawBodyBattery(dc as Graphics.Dc, x as Float, y as Float, color as Graphics.ColorType, level as Float) as Void {
        var s = Screen.scale;
        dc.setColor(color, Graphics.COLOR_TRANSPARENT);
        dc.setPenWidth(Screen.strokeWidth(1, s));
        dc.drawRectangle(x - 3.5 * s, y - 5.5 * s, 7 * s, 12 * s);
        dc.fillRectangle(x - 1.5 * s, y - 7 * s, 3 * s, 1.5 * s);
        var h = 9 * s * level;
        dc.fillRectangle(x - 2 * s, y + 5 * s - h, 4 * s, h);
    }

    function drawSunEvent(dc as Graphics.Dc, x as Float, y as Float, color as Graphics.ColorType, rise as Boolean) as Void {
        var s = Screen.scale;
        dc.setColor(color, Graphics.COLOR_TRANSPARENT);
        dc.setClip(x - 8 * s, y - 8 * s, 16 * s, 11 * s);
        dc.fillCircle(x, y + 3 * s, 4.5 * s);
        dc.clearClip();
        dc.setPenWidth(Screen.strokeWidth(1.5, s));
        dc.drawLine(x - 7 * s, y + 4 * s, x + 7 * s, y + 4 * s);
        if (rise) {
            dc.fillPolygon([[x, y - 8 * s], [x - 3 * s, y - 4.5 * s], [x + 3 * s, y - 4.5 * s]]);
        } else {
            dc.fillPolygon([[x, y - 4.5 * s], [x - 3 * s, y - 8 * s], [x + 3 * s, y - 8 * s]]);
        }
    }

    function drawBell(dc as Graphics.Dc, x as Float, y as Float, color as Graphics.ColorType) as Void {
        var s = Screen.scale;
        dc.setColor(color, Graphics.COLOR_TRANSPARENT);
        dc.fillCircle(x, y - 6.5 * s, 1.2 * s);
        dc.fillCircle(x, y - 1.5 * s, 4.5 * s);
        dc.fillRectangle(x - 4.5 * s, y - 1.5 * s, 9 * s, 4.5 * s);
        dc.fillPolygon([[x - 4.5 * s, y + 2.5 * s], [x + 4.5 * s, y + 2.5 * s], [x + 6.5 * s, y + 4.5 * s], [x - 6.5 * s, y + 4.5 * s]]);
        dc.fillCircle(x, y + 6 * s, 1.6 * s);
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
        var s = Screen.scale;
        if (kind == WEATHER_ICON_CLEAR) {
            drawSun(dc, x, y, Graphics.COLOR_YELLOW, 3.6);
        } else if (kind == WEATHER_ICON_PARTLY_CLOUDY) {
            drawSun(dc, x + 2.5 * s, y - 2.5 * s, Graphics.COLOR_YELLOW, 2.8);
            drawCloud(dc, x - 1 * s, y + 1.5 * s, Graphics.COLOR_WHITE);
        } else if (kind == WEATHER_ICON_RAIN) {
            drawCloud(dc, x, y - 3 * s, Graphics.COLOR_LT_GRAY);
            dc.setColor(Graphics.COLOR_BLUE, Graphics.COLOR_TRANSPARENT);
            dc.setPenWidth(Screen.strokeWidth(1.5, s));
            dc.drawLine(x - 4 * s, y + 4 * s, x - 5.5 * s, y + 7.5 * s);
            dc.drawLine(x, y + 4 * s, x - 1.5 * s, y + 7.5 * s);
            dc.drawLine(x + 4 * s, y + 4 * s, x + 2.5 * s, y + 7.5 * s);
        } else if (kind == WEATHER_ICON_SNOW) {
            drawCloud(dc, x, y - 3 * s, Graphics.COLOR_LT_GRAY);
            dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
            dc.fillCircle(x - 4 * s, y + 6 * s, 1.2 * s);
            dc.fillCircle(x, y + 6 * s, 1.2 * s);
            dc.fillCircle(x + 4 * s, y + 6 * s, 1.2 * s);
        } else if (kind == WEATHER_ICON_THUNDER) {
            drawCloud(dc, x, y - 3 * s, Graphics.COLOR_LT_GRAY);
            dc.setColor(Graphics.COLOR_YELLOW, Graphics.COLOR_TRANSPARENT);
            dc.fillPolygon([
                [x + 1 * s, y + 1 * s], [x - 2.5 * s, y + 5 * s], [x, y + 5 * s],
                [x - 1 * s, y + 8.5 * s], [x + 2.5 * s, y + 4 * s], [x, y + 4 * s]
            ]);
        } else if (kind == WEATHER_ICON_FOG) {
            dc.setColor(Graphics.COLOR_LT_GRAY, Graphics.COLOR_TRANSPARENT);
            dc.setPenWidth(Screen.strokeWidth(2, s));
            dc.drawLine(x - 6 * s, y - 4 * s, x + 6 * s, y - 4 * s);
            dc.drawLine(x - 6 * s, y, x + 6 * s, y);
            dc.drawLine(x - 6 * s, y + 4 * s, x + 6 * s, y + 4 * s);
        } else {
            // WEATHER_ICON_CLOUDY, and the safe default for anything unmapped.
            drawCloud(dc, x, y, Graphics.COLOR_LT_GRAY);
        }
    }
}
