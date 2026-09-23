import Toybox.Lang;
import Toybox.Graphics;
import Toybox.System;
import Toybox.Math;
import Toybox.ActivityMonitor;
import Toybox.Activity;
import Toybox.Time;
import Toybox.Time.Gregorian;

// What a Slot draws: either a head text (Date only) or an icon (every other Readout, dispatched
// by `kind` through Readouts.drawIcon), plus a value string and colors.
class ReadoutContent {
    var kind as Number;
    var head as String?;
    var text as String;
    var iconColor as Graphics.ColorType;
    var textColor as Graphics.ColorType;

    function initialize(
        kind as Number,
        head as String?,
        text as String,
        iconColor as Graphics.ColorType,
        textColor as Graphics.ColorType
    ) {
        self.kind = kind;
        self.head = head;
        self.text = text;
        self.iconColor = iconColor;
        self.textColor = textColor;
    }
}

// Ported from prototype/index.html's READOUTS table. The property/setting values (ticket 03's
// "Decisions" explains why these are Numbers, not strings) match this module's constant order.
module Readouts {
    const DATE = 0;
    const STEPS = 1;
    const WEATHER = 2;
    const HEART_RATE = 3;
    const BODY_BATTERY = 4;
    const SUN = 5;
    const NOTIFICATIONS = 6;
    const BATTERY = 7;
    const EMPTY = 8;

    // Pure: ticket 02's English-only, uppercase weekday abbreviation.
    function dateHead(dayOfWeek as String) as String {
        return dayOfWeek.toUpper();
    }

    // Pure: "--" for missing data, otherwise the value as text. No Readout in this design
    // formats a number any other way (no decimals, no thousands separator).
    function formatOrDash(value as Numeric?) as String {
        if (value == null) {
            return "--";
        }
        return value.toString();
    }

    // Pure: the Steps icon turns green once the goal is reached.
    function stepsIconColor(steps as Number?, goal as Number?) as Graphics.ColorType {
        if (steps != null && goal != null && steps >= goal) {
            return Graphics.COLOR_GREEN;
        }
        return Graphics.COLOR_WHITE;
    }

    // Pure: battery percentage, rounded, with a trailing %.
    function batteryText(percent as Numeric) as String {
        return Math.round(percent).toNumber().toString() + "%";
    }

    function dateReadout() as ReadoutContent {
        var info = Gregorian.info(Time.now(), Time.FORMAT_MEDIUM);
        var head = dateHead(info.day_of_week as String);
        return new ReadoutContent(DATE, head, (info.day as Number).toString(), Graphics.COLOR_WHITE, Graphics.COLOR_WHITE);
    }

    function stepsReadout() as ReadoutContent {
        var info = ActivityMonitor.getInfo();
        return new ReadoutContent(
            STEPS, null, formatOrDash(info.steps), stepsIconColor(info.steps, info.stepGoal), Graphics.COLOR_WHITE
        );
    }

    function heartRateReadout() as ReadoutContent {
        var info = Activity.getActivityInfo();
        var hr = info != null ? info.currentHeartRate : null;
        return new ReadoutContent(HEART_RATE, null, formatOrDash(hr), Graphics.COLOR_RED, Graphics.COLOR_WHITE);
    }

    function batteryReadout() as ReadoutContent {
        var percent = System.getSystemStats().battery;
        return new ReadoutContent(BATTERY, null, batteryText(percent), Graphics.COLOR_WHITE, Graphics.COLOR_WHITE);
    }

    // Wired up for real in ticket 08; until then, weather shows a grey cloud and "--" (ticket
    // 07's explicit scope note), the same "no data" rendering ticket 08's real Weather Readout
    // uses when Weather.getCurrentConditions() returns null.
    function weatherPlaceholder() as ReadoutContent {
        return new ReadoutContent(WEATHER, null, "--", Graphics.COLOR_DK_GRAY, Graphics.COLOR_WHITE);
    }

    // Returns null for an empty Slot, and (until ticket 08) for Body Battery, Sunrise/sunset
    // and Notifications, which aren't implemented yet.
    function get(kind as Number) as ReadoutContent? {
        if (kind == DATE) {
            return dateReadout();
        } else if (kind == STEPS) {
            return stepsReadout();
        } else if (kind == HEART_RATE) {
            return heartRateReadout();
        } else if (kind == BATTERY) {
            return batteryReadout();
        } else if (kind == WEATHER) {
            return weatherPlaceholder();
        }
        return null;
    }

    function drawIcon(dc as Graphics.Dc, kind as Number, x as Float, y as Float, color as Graphics.ColorType) as Void {
        if (kind == STEPS) {
            Icons.drawSteps(dc, x, y, color);
        } else if (kind == HEART_RATE) {
            Icons.drawHeart(dc, x, y, color);
        } else if (kind == BATTERY) {
            Icons.drawBatteryLevel(dc, x, y, color, System.getSystemStats().battery / 100.0);
        } else if (kind == WEATHER) {
            Icons.drawCloud(dc, x, y, color);
        }
    }
}
