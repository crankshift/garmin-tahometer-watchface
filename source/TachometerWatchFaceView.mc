import Toybox.Application;
import Toybox.Graphics;
import Toybox.Lang;
import Toybox.System;
import Toybox.WatchUi;

class TachometerWatchFaceView extends WatchUi.WatchFace {
    private var _tachometerNumeralFont as Graphics.FontDefinition?;
    private var _gearFont as Graphics.FontDefinition?;
    private var _smallFont as Graphics.FontDefinition?;

    function initialize() {
        WatchFace.initialize();
    }

    function onLayout(dc as Graphics.Dc) as Void {
        _tachometerNumeralFont = WatchUi.loadResource(Rez.Fonts.TachometerNumeralFont) as Graphics.FontDefinition;
        _gearFont = WatchUi.loadResource(Rez.Fonts.GearFont) as Graphics.FontDefinition;
        _smallFont = WatchUi.loadResource(Rez.Fonts.SmallFont) as Graphics.FontDefinition;
    }

    function onUpdate(dc as Graphics.Dc) as Void {
        dc.setAntiAlias(true);
        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_BLACK);
        dc.clear();

        var minute = System.getClockTime().min;
        var minuteStyle = Application.Properties.getValue("MinuteStyle") as Number;

        Tachometer.drawTachometer(dc, minute, minuteStyle, _tachometerNumeralFont as Graphics.FontDefinition);
        if (minuteStyle == Tachometer.STYLE_NEEDLE) {
            Tachometer.drawNeedle(dc, minute);
        }
        Gear.draw(dc, _gearFont as Graphics.FontDefinition, _smallFont as Graphics.FontDefinition);
    }
}
