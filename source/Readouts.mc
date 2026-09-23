import Toybox.Lang;
import Toybox.Graphics;
import Toybox.Application;
import Toybox.System;
import Toybox.Math;
import Toybox.ActivityMonitor;
import Toybox.Activity;
import Toybox.SensorHistory;
import Toybox.Weather;
import Toybox.Position;
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
    // Meaning depends on kind: Weather -> Icons.WEATHER_ICON_* (or Readouts.WEATHER_NO_DATA),
    // Body Battery -> level 0-100, Sunrise/sunset -> 1 if the next event is sunrise, 0 if
    // sunset. Unused (0) for every other kind.
    var extra as Number;

    function initialize(
        kind as Number,
        head as String?,
        text as String,
        iconColor as Graphics.ColorType,
        textColor as Graphics.ColorType,
        extra as Number
    ) {
        self.kind = kind;
        self.head = head;
        self.text = text;
        self.iconColor = iconColor;
        self.textColor = textColor;
        self.extra = extra;
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

    const WEATHER_NO_DATA = -1;

    const TEMP_FEELS_LIKE = 0;
    const TEMP_ACTUAL = 1;

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

    // Pure: HH:MM (24-hour, zero-padded) or H:MM (12-hour, no leading zero).
    function formatClock(hour as Number, minute as Number, is24Hour as Boolean) as String {
        var mm = minute < 10 ? "0" + minute.toString() : minute.toString();
        if (is24Hour) {
            var hh = hour < 10 ? "0" + hour.toString() : hour.toString();
            return hh + ":" + mm;
        }
        var h12 = hour % 12;
        if (h12 == 0) {
            h12 = 12;
        }
        return h12.toString() + ":" + mm;
    }

    // Pure: Celsius to display text in the given unit system, "--" if missing.
    function temperatureText(celsius as Numeric?, unitsSystem as System.UnitsSystem) as String {
        if (celsius == null) {
            return "--";
        }
        var value = celsius;
        if (unitsSystem == System.UNIT_STATUTE) {
            value = celsius * 9.0 / 5.0 + 32.0;
        }
        return Math.round(value).toNumber().toString() + "°";
    }

    // Pure: which of the two configured temperatures to show.
    function chosenTemperature(feelsLike as Numeric?, actual as Numeric?, tempSetting as Number) as Numeric? {
        return tempSetting == TEMP_ACTUAL ? actual : feelsLike;
    }

    // Pure: maps the platform's 50+ CONDITION_* constants onto the prototype's seven icons.
    // Kept as one table, as the ticket asks, rather than scattered across call sites.
    function weatherIconKind(condition as Number?) as Number {
        if (condition == Weather.CONDITION_CLEAR || condition == Weather.CONDITION_FAIR ||
            condition == Weather.CONDITION_MOSTLY_CLEAR) {
            return Icons.WEATHER_ICON_CLEAR;
        }
        if (condition == Weather.CONDITION_PARTLY_CLOUDY || condition == Weather.CONDITION_PARTLY_CLEAR ||
            condition == Weather.CONDITION_MOSTLY_CLOUDY || condition == Weather.CONDITION_THIN_CLOUDS) {
            return Icons.WEATHER_ICON_PARTLY_CLOUDY;
        }
        if (condition == Weather.CONDITION_FOG || condition == Weather.CONDITION_HAZE ||
            condition == Weather.CONDITION_HAZY || condition == Weather.CONDITION_MIST ||
            condition == Weather.CONDITION_SMOKE || condition == Weather.CONDITION_DUST ||
            condition == Weather.CONDITION_SAND || condition == Weather.CONDITION_SANDSTORM ||
            condition == Weather.CONDITION_VOLCANIC_ASH) {
            return Icons.WEATHER_ICON_FOG;
        }
        if (condition == Weather.CONDITION_THUNDERSTORMS || condition == Weather.CONDITION_SCATTERED_THUNDERSTORMS ||
            condition == Weather.CONDITION_CHANCE_OF_THUNDERSTORMS || condition == Weather.CONDITION_TORNADO ||
            condition == Weather.CONDITION_HURRICANE || condition == Weather.CONDITION_TROPICAL_STORM) {
            return Icons.WEATHER_ICON_THUNDER;
        }
        if (condition == Weather.CONDITION_SNOW || condition == Weather.CONDITION_LIGHT_SNOW ||
            condition == Weather.CONDITION_HEAVY_SNOW || condition == Weather.CONDITION_FLURRIES ||
            condition == Weather.CONDITION_CHANCE_OF_SNOW || condition == Weather.CONDITION_CLOUDY_CHANCE_OF_SNOW ||
            condition == Weather.CONDITION_ICE_SNOW || condition == Weather.CONDITION_ICE ||
            condition == Weather.CONDITION_SLEET || condition == Weather.CONDITION_HAIL ||
            condition == Weather.CONDITION_WINTRY_MIX || condition == Weather.CONDITION_RAIN_SNOW ||
            condition == Weather.CONDITION_LIGHT_RAIN_SNOW || condition == Weather.CONDITION_HEAVY_RAIN_SNOW ||
            condition == Weather.CONDITION_CLOUDY_CHANCE_OF_RAIN_SNOW ||
            condition == Weather.CONDITION_CHANCE_OF_RAIN_SNOW || condition == Weather.CONDITION_FREEZING_RAIN) {
            return Icons.WEATHER_ICON_SNOW;
        }
        if (condition == Weather.CONDITION_RAIN || condition == Weather.CONDITION_LIGHT_RAIN ||
            condition == Weather.CONDITION_HEAVY_RAIN || condition == Weather.CONDITION_DRIZZLE ||
            condition == Weather.CONDITION_SHOWERS || condition == Weather.CONDITION_LIGHT_SHOWERS ||
            condition == Weather.CONDITION_HEAVY_SHOWERS || condition == Weather.CONDITION_CHANCE_OF_SHOWERS ||
            condition == Weather.CONDITION_SCATTERED_SHOWERS || condition == Weather.CONDITION_CLOUDY_CHANCE_OF_RAIN ||
            condition == Weather.CONDITION_SQUALL || condition == Weather.CONDITION_UNKNOWN_PRECIPITATION) {
            return Icons.WEATHER_ICON_RAIN;
        }
        // CONDITION_CLOUDY, CONDITION_WINDY, CONDITION_UNKNOWN, null, and anything unmapped.
        return Icons.WEATHER_ICON_CLOUDY;
    }

    // Pure: which sunrise/sunset moment is "next", given already-fetched moments. Null
    // propagates to a null result (ticket 08: "-- when there is no location or either call
    // returns null").
    function chooseNextSunEvent(
        now as Time.Moment,
        todaySunrise as Time.Moment?,
        todaySunset as Time.Moment?,
        tomorrowSunrise as Time.Moment?
    ) as Dictionary? {
        if (todaySunrise == null || todaySunset == null) {
            return null;
        }
        if (now.lessThan(todaySunrise)) {
            return { :isRise => true, :moment => todaySunrise };
        }
        if (now.lessThan(todaySunset)) {
            return { :isRise => false, :moment => todaySunset };
        }
        if (tomorrowSunrise == null) {
            return null;
        }
        return { :isRise => true, :moment => tomorrowSunrise };
    }

    function dateReadout() as ReadoutContent {
        var info = Gregorian.info(Time.now(), Time.FORMAT_MEDIUM);
        var head = dateHead(info.day_of_week as String);
        return new ReadoutContent(DATE, head, (info.day as Number).toString(), Graphics.COLOR_WHITE, Graphics.COLOR_WHITE, 0);
    }

    function stepsReadout() as ReadoutContent {
        var info = ActivityMonitor.getInfo();
        return new ReadoutContent(
            STEPS, null, formatOrDash(info.steps), stepsIconColor(info.steps, info.stepGoal), Graphics.COLOR_WHITE, 0
        );
    }

    function heartRateReadout() as ReadoutContent {
        var info = Activity.getActivityInfo();
        var hr = info != null ? info.currentHeartRate : null;
        return new ReadoutContent(HEART_RATE, null, formatOrDash(hr), Graphics.COLOR_RED, Graphics.COLOR_WHITE, 0);
    }

    function batteryReadout() as ReadoutContent {
        var percent = System.getSystemStats().battery;
        return new ReadoutContent(BATTERY, null, batteryText(percent), Graphics.COLOR_WHITE, Graphics.COLOR_WHITE, 0);
    }

    function weatherNoData() as ReadoutContent {
        return new ReadoutContent(WEATHER, null, "--", Graphics.COLOR_DK_GRAY, Graphics.COLOR_WHITE, WEATHER_NO_DATA);
    }

    function weatherReadout() as ReadoutContent {
        var conditions = Weather.getCurrentConditions();
        if (conditions == null) {
            return weatherNoData();
        }
        var tempSetting = Application.Properties.getValue("WeatherTemperature") as Number;
        var celsius = chosenTemperature(conditions.feelsLikeTemperature, conditions.temperature, tempSetting);
        var text = temperatureText(celsius, System.getDeviceSettings().temperatureUnits);
        var iconKind = weatherIconKind(conditions.condition);
        return new ReadoutContent(WEATHER, null, text, Graphics.COLOR_WHITE, Graphics.COLOR_WHITE, iconKind);
    }

    function bodyBatteryReadout() as ReadoutContent {
        var level = latestBodyBatteryLevel();
        return new ReadoutContent(
            BODY_BATTERY, null, formatOrDash(level), Graphics.COLOR_BLUE, Graphics.COLOR_WHITE, level != null ? level : 0
        );
    }

    function latestBodyBatteryLevel() as Number? {
        if (!(Toybox has :SensorHistory) || !(Toybox.SensorHistory has :getBodyBatteryHistory)) {
            return null;
        }
        var iterator = SensorHistory.getBodyBatteryHistory({ :period => 1, :order => SensorHistory.ORDER_NEWEST_FIRST });
        var sample = iterator.next();
        if (sample == null || sample.data == null) {
            return null;
        }
        return sample.data as Number;
    }

    function sunNoData() as ReadoutContent {
        return new ReadoutContent(SUN, null, "--", Graphics.COLOR_YELLOW, Graphics.COLOR_WHITE, 1);
    }

    function sunReadout() as ReadoutContent {
        var conditions = Weather.getCurrentConditions();
        var location = conditions != null ? conditions.observationLocationPosition : null;
        if (location == null) {
            return sunNoData();
        }
        var now = Time.now();
        var tomorrow = now.add(new Time.Duration(Gregorian.SECONDS_PER_DAY));
        var event = chooseNextSunEvent(
            now,
            Weather.getSunrise(location, now),
            Weather.getSunset(location, now),
            Weather.getSunrise(location, tomorrow)
        );
        if (event == null) {
            return sunNoData();
        }
        var moment = event.get(:moment) as Time.Moment;
        var info = Gregorian.info(moment, Time.FORMAT_SHORT);
        var is24Hour = System.getDeviceSettings().is24Hour;
        var text = formatClock(info.hour as Number, info.min as Number, is24Hour);
        var isRise = event.get(:isRise) as Boolean;
        return new ReadoutContent(SUN, null, text, Graphics.COLOR_YELLOW, Graphics.COLOR_WHITE, isRise ? 1 : 0);
    }

    function notificationsReadout() as ReadoutContent {
        var count = System.getDeviceSettings().notificationCount;
        var color = count > 0 ? Graphics.COLOR_WHITE : Graphics.COLOR_DK_GRAY;
        return new ReadoutContent(NOTIFICATIONS, null, count.toString(), color, color, 0);
    }

    // Returns null for an empty Slot.
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
            return weatherReadout();
        } else if (kind == BODY_BATTERY) {
            return bodyBatteryReadout();
        } else if (kind == SUN) {
            return sunReadout();
        } else if (kind == NOTIFICATIONS) {
            return notificationsReadout();
        }
        return null;
    }

    function drawIcon(
        dc as Graphics.Dc,
        kind as Number,
        x as Float,
        y as Float,
        color as Graphics.ColorType,
        extra as Number
    ) as Void {
        if (kind == STEPS) {
            Icons.drawSteps(dc, x, y, color);
        } else if (kind == HEART_RATE) {
            Icons.drawHeart(dc, x, y, color);
        } else if (kind == BATTERY) {
            Icons.drawBatteryLevel(dc, x, y, color, System.getSystemStats().battery / 100.0);
        } else if (kind == WEATHER) {
            if (extra == WEATHER_NO_DATA) {
                Icons.drawCloud(dc, x, y, color);
            } else {
                Icons.drawWeatherIcon(dc, x, y, extra);
            }
        } else if (kind == BODY_BATTERY) {
            Icons.drawBodyBattery(dc, x, y, color, extra / 100.0);
        } else if (kind == SUN) {
            Icons.drawSunEvent(dc, x, y, color, extra == 1);
        } else if (kind == NOTIFICATIONS) {
            Icons.drawBell(dc, x, y, color);
        }
    }
}
