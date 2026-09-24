import Toybox.Lang;
import Toybox.Graphics;
import Toybox.Math;
import Toybox.System;

// Ported from prototype/index.html's drawFuelGauge/lowFuelLampColor and the pump/bolt/sun icons.
module FuelGauge {
    const FROM_DEG = 235.0f;
    const SPAN_DEG = 70.0f;
    const SEGMENTS = 10;
    const LAMP_DEG = FROM_DEG - 12; // 223
    const CHARGE_DEG = FROM_DEG + SPAN_DEG + 12; // 317

    // Written for the 260 px screen and scaled by the screen's radius (docs/specs/multi-device.md
    // "Scaling"). Built once in fit. The angles above don't scale.
    class Layout {
        var rBand as Float;
        var bandW as Number;
        var iconR as Float;

        function initialize(radius as Float) {
            var s = Screen.scaleFor(radius);
            rBand = radius - 6 * s;
            bandW = Screen.penWidth(8, s);
            iconR = rBand - 10 * s;
        }
    }

    // Starts as the 260 px layout; the view calls fit from onLayout.
    var layout as Layout = new Layout(Screen.V1_RADIUS);

    function fit(radius as Float) as Void {
        layout = new Layout(radius);
    }

    // Pure: lit segment count for a battery percentage, rounded to nearest (9% -> 1, 4% -> 0).
    function litSegments(batteryPercent as Numeric) as Number {
        return Math.round(batteryPercent / 10.0).toNumber();
    }

    // Pure: Low-Fuel Lamp color thresholds.
    function lowFuelLampColor(batteryPercent as Numeric) as Graphics.ColorType {
        if (batteryPercent <= 10) {
            return Graphics.COLOR_RED;
        } else if (batteryPercent <= 20) {
            return Graphics.COLOR_YELLOW;
        }
        return Graphics.COLOR_DK_GRAY;
    }

    function drawSegments(dc as Graphics.Dc, batteryPercent as Numeric) as Void {
        var lit = litSegments(batteryPercent);
        var segSpan = SPAN_DEG.toFloat() / SEGMENTS;
        dc.setPenWidth(layout.bandW);
        for (var i = 0; i < SEGMENTS; i += 1) {
            dc.setColor(i < lit ? Graphics.COLOR_WHITE : Graphics.COLOR_DK_GRAY, Graphics.COLOR_TRANSPARENT);
            dc.drawArc(
                Screen.cx,
                Screen.cy,
                layout.rBand,
                Graphics.ARC_COUNTER_CLOCKWISE,
                FROM_DEG + i * segSpan + 0.8,
                FROM_DEG + (i + 1) * segSpan - 0.8
            );
        }
    }

    function drawLowFuelLamp(dc as Graphics.Dc, batteryPercent as Numeric) as Void {
        var pos = Geometry.polar(LAMP_DEG, layout.iconR);
        Icons.drawPump(dc, pos[0], pos[1], lowFuelLampColor(batteryPercent));
    }

    // Bolt while cable charging; otherwise a sun while solar intensity is above zero (the
    // value can be null); otherwise nothing.
    function drawChargingIcon(dc as Graphics.Dc, charging as Boolean, solarIntensity as Number?) as Void {
        var pos = Geometry.polar(CHARGE_DEG, layout.iconR);
        if (charging) {
            Icons.drawBolt(dc, pos[0], pos[1], Graphics.COLOR_GREEN);
        } else if (solarIntensity != null && solarIntensity > 0) {
            Icons.drawSun(dc, pos[0], pos[1], Graphics.COLOR_YELLOW, 3.0);
        }
    }

    function draw(dc as Graphics.Dc) as Void {
        var stats = System.getSystemStats();
        drawSegments(dc, stats.battery);
        drawLowFuelLamp(dc, stats.battery);
        drawChargingIcon(dc, stats.charging, stats.solarIntensity);
    }
}
