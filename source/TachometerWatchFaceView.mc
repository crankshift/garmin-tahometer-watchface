import Toybox.Application;
import Toybox.Graphics;
import Toybox.Lang;
import Toybox.System;
import Toybox.WatchUi;

class TachometerWatchFaceView extends WatchUi.WatchFace {
    private var _tachometerNumeralFont as Graphics.FontDefinition?;
    private var _gearFont as Graphics.FontDefinition?;
    private var _smallFont as Graphics.FontDefinition?;

    // Rev Bar power state (docs/tickets/05). Starts awake: the watch face only appears after
    // the user raises their wrist, and onEnterSleep fires once the system judges it idle.
    private var _awake as Boolean = true;
    private var _budgetExceeded as Boolean = false;

    function initialize() {
        WatchFace.initialize();
    }

    function onLayout(dc as Graphics.Dc) as Void {
        _tachometerNumeralFont = WatchUi.loadResource(Rez.Fonts.TachometerNumeralFont) as Graphics.FontDefinition;
        _gearFont = WatchUi.loadResource(Rez.Fonts.GearFont) as Graphics.FontDefinition;
        _smallFont = WatchUi.loadResource(Rez.Fonts.SmallFont) as Graphics.FontDefinition;
    }

    // True while the Rev Bar should be running, awake or in low power with the setting on.
    private function revBarVisible() as Boolean {
        return _awake || (alwaysOnRevBar() && !_budgetExceeded);
    }

    private function alwaysOnRevBar() as Boolean {
        return Application.Properties.getValue("AlwaysOnRevBar") as Boolean;
    }

    function onUpdate(dc as Graphics.Dc) as Void {
        dc.setAntiAlias(true);
        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_BLACK);
        dc.clear();

        var clockTime = System.getClockTime();
        var minute = clockTime.min;
        var minuteStyle = Application.Properties.getValue("MinuteStyle") as Number;

        Tachometer.drawTachometer(dc, minute, minuteStyle, _tachometerNumeralFont as Graphics.FontDefinition);
        if (revBarVisible()) {
            RevBar.draw(dc, clockTime.sec);
        }
        if (minuteStyle == Tachometer.STYLE_NEEDLE) {
            Tachometer.drawNeedle(dc, minute);
        }
        Gear.draw(dc, _gearFont as Graphics.FontDefinition, _smallFont as Graphics.FontDefinition);
    }

    // Low power, once a second: draw only the newest Rev Bar segment, clipped.
    function onPartialUpdate(dc as Graphics.Dc) as Void {
        if (!revBarVisible()) {
            return;
        }
        RevBar.drawPartial(dc, System.getClockTime().sec);
    }

    function onEnterSleep() as Void {
        _awake = false;
        WatchUi.requestUpdate();
    }

    function onExitSleep() as Void {
        _awake = true;
        _budgetExceeded = false;
    }

    // Relayed from TachometerWatchFaceDelegate.onPowerBudgetExceeded. Hides the Rev Bar until
    // the next onExitSleep (docs/tickets/05 "Known limitation").
    function onPowerBudgetExceeded() as Void {
        _budgetExceeded = true;
    }
}
