import Toybox.Application;
import Toybox.Graphics;
import Toybox.Lang;
import Toybox.System;
import Toybox.WatchUi;

class TachometerWatchFaceView extends WatchUi.WatchFace {
    private var _tachometerNumeralFont as Graphics.FontDefinition?;
    private var _gearFont as Graphics.FontDefinition?;
    private var _smallFont as Graphics.FontDefinition?;
    private var _slotValueFont as Graphics.FontDefinition?;
    // AMOLED only: the Gear's glow under it, and its outline in the always-on view.
    private var _gearGlowFont as Graphics.FontDefinition?;
    private var _gearOutlineFont as Graphics.FontDefinition?;

    // Rev Bar power state (docs/tickets/05). Starts awake: the watch face only appears after
    // the user raises their wrist, and onEnterSleep fires once the system judges it idle.
    private var _awake as Boolean = true;
    private var _budgetExceeded as Boolean = false;

    function initialize() {
        WatchFace.initialize();
    }

    function onLayout(dc as Graphics.Dc) as Void {
        // Every fixed pixel value is written for 260 px; scale them to this screen once here, so
        // onUpdate and onPartialUpdate only read them (docs/specs/multi-device.md "Scaling").
        Screen.fit(dc.getWidth(), System.getDeviceSettings().requiresBurnInProtection);
        Glow.fit(Screen.radius);
        Tachometer.fit(Screen.radius);
        RevBar.fit(Screen.radius);
        Gear.fit(Screen.radius);
        FuelGauge.fit(Screen.radius);
        Slots.fit(Screen.radius);

        _tachometerNumeralFont = WatchUi.loadResource(Rez.Fonts.TachometerNumeralFont) as Graphics.FontDefinition;
        _gearFont = WatchUi.loadResource(Rez.Fonts.GearFont) as Graphics.FontDefinition;
        _smallFont = WatchUi.loadResource(Rez.Fonts.SmallFont) as Graphics.FontDefinition;
        _slotValueFont = WatchUi.loadResource(Rez.Fonts.SlotValueFont) as Graphics.FontDefinition;
        if (Screen.amoled) {
            // The MIP watches only have one-glyph stand-ins for these two, so they never load them.
            _gearGlowFont = WatchUi.loadResource(Rez.Fonts.GearGlowFont) as Graphics.FontDefinition;
            _gearOutlineFont = WatchUi.loadResource(Rez.Fonts.GearOutlineFont) as Graphics.FontDefinition;
        }
    }

    // True while the Rev Bar should be running, awake or in low power with the setting on (MIP only).
    private function revBarVisible() as Boolean {
        return RevBar.isVisible(_awake, Screen.amoled, alwaysOnRevBar(), _budgetExceeded);
    }

    private function alwaysOnRevBar() as Boolean {
        return Application.Properties.getValue("AlwaysOnRevBar") as Boolean;
    }

    function onUpdate(dc as Graphics.Dc) as Void {
        dc.setAntiAlias(true);
        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_BLACK);
        dc.clear();

        var clockTime = System.getClockTime();
        if (AlwaysOn.isActive(Screen.amoled, _awake)) {
            drawAlwaysOn(dc, clockTime.min);
        } else {
            drawAwake(dc, clockTime.min, clockTime.sec);
        }
    }

    private function drawAwake(dc as Graphics.Dc, minute as Number, second as Number) as Void {
        var minuteStyle = Application.Properties.getValue("MinuteStyle") as Number;

        if (Screen.amoled) {
            // The glow goes down first, so the face sits on top of it.
            Tachometer.drawGlow(dc, minute, minuteStyle);
            RevBar.drawGlow(dc, second);
            Gear.drawGlow(dc, _gearGlowFont as Graphics.FontDefinition, _gearFont as Graphics.FontDefinition);
        }
        Tachometer.drawTachometer(dc, minute, minuteStyle, _tachometerNumeralFont as Graphics.FontDefinition);
        if (revBarVisible()) {
            RevBar.draw(dc, second);
        }
        if (minuteStyle == Tachometer.STYLE_NEEDLE) {
            Tachometer.drawNeedle(dc, minute);
        }
        Gear.draw(dc, _gearFont as Graphics.FontDefinition, _smallFont as Graphics.FontDefinition, Graphics.COLOR_WHITE);
        FuelGauge.draw(dc);
        drawSlots(dc, false);
    }

    // AMOLED, asleep: the dimmed face (docs/specs/multi-device.md "AMOLED, always-on"), which has no Rev Bar.
    private function drawAlwaysOn(dc as Graphics.Dc, minute as Number) as Void {
        Tachometer.drawAlwaysOn(dc, minute, _tachometerNumeralFont as Graphics.FontDefinition);
        Gear.draw(dc, _gearOutlineFont as Graphics.FontDefinition, _smallFont as Graphics.FontDefinition, Graphics.COLOR_LT_GRAY);
        FuelGauge.drawAlwaysOn(dc);
        drawSlots(dc, true);
    }

    private function drawSlots(dc as Graphics.Dc, alwaysOn as Boolean) as Void {
        Slots.draw(
            dc,
            Application.Properties.getValue("LeftSlotReadout") as Number,
            Application.Properties.getValue("CenterSlotReadout") as Number,
            Application.Properties.getValue("RightSlotReadout") as Number,
            Application.Properties.getValue("BottomSlotReadout") as Number,
            _smallFont as Graphics.FontDefinition,
            _slotValueFont as Graphics.FontDefinition,
            alwaysOn
        );
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
