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

    // Battery percentage at or below which the Low-Fuel Lamp is amber, and red.
    const LAMP_AMBER_AT = 20;
    const LAMP_RED_AT = 10;

    // Written for the 260 px screen and scaled by the screen's radius (docs/specs/multi-device.md
    // "Scaling"). Built once in fit. The angles above don't scale.
    class Layout {
        var rBand as Float;
        var bandW as Number;
        var alwaysOnBandW as Number;
        var iconR as Float;

        function initialize(radius as Float) {
            var s = Screen.scaleFor(radius);
            rBand = radius - 6 * s;
            bandW = Screen.penWidth(8, s);
            alwaysOnBandW = Screen.penWidth(3, s);
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
        if (batteryPercent <= LAMP_RED_AT) {
            return Graphics.COLOR_RED;
        } else if (batteryPercent <= LAMP_AMBER_AT) {
            return Graphics.COLOR_YELLOW;
        }
        return Graphics.COLOR_DK_GRAY;
    }

    // Pure: the always-on view shows the Low-Fuel Lamp only once it is amber or red.
    function alwaysOnLampVisible(batteryPercent as Numeric) as Boolean {
        return batteryPercent <= LAMP_AMBER_AT;
    }

    function drawSegment(dc as Graphics.Dc, index as Number) as Void {
        var segSpan = SPAN_DEG.toFloat() / SEGMENTS;
        dc.drawArc(
            Screen.cx,
            Screen.cy,
            layout.rBand,
            Graphics.ARC_COUNTER_CLOCKWISE,
            FROM_DEG + index * segSpan + 0.8,
            FROM_DEG + (index + 1) * segSpan - 0.8
        );
    }

    function drawSegments(dc as Graphics.Dc, batteryPercent as Numeric) as Void {
        var lit = litSegments(batteryPercent);
        dc.setPenWidth(layout.bandW);
        for (var i = 0; i < SEGMENTS; i += 1) {
            dc.setColor(i < lit ? Graphics.COLOR_WHITE : Graphics.COLOR_DK_GRAY, Graphics.COLOR_TRANSPARENT);
            drawSegment(dc, i);
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

    // The always-on view's Fuel Gauge: a thin band of the lit segments only, in light grey, and the
    // Low-Fuel Lamp once the battery is at 20% or below. No charging icon.
    function drawAlwaysOn(dc as Graphics.Dc) as Void {
        var batteryPercent = System.getSystemStats().battery;
        var lit = litSegments(batteryPercent);
        dc.setPenWidth(layout.alwaysOnBandW);
        dc.setColor(Graphics.COLOR_LT_GRAY, Graphics.COLOR_TRANSPARENT);
        for (var i = 0; i < lit; i += 1) {
            drawSegment(dc, i);
        }
        if (alwaysOnLampVisible(batteryPercent)) {
            drawLowFuelLamp(dc, batteryPercent);
        }
    }
}
