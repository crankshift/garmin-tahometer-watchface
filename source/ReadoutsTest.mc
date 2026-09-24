import Toybox.Lang;
import Toybox.Graphics;
import Toybox.System;
import Toybox.Weather;
import Toybox.Time;
import Toybox.Test;

(:test)
function testDateHeadIsUppercase(logger as Test.Logger) as Boolean {
    return Readouts.dateHead("Wed").equals("WED");
}

(:test)
function testFormatOrDashShowsDashForMissingData(logger as Test.Logger) as Boolean {
    return Readouts.formatOrDash(null).equals("--");
}

(:test)
function testFormatOrDashShowsTheRawValue(logger as Test.Logger) as Boolean {
    return Readouts.formatOrDash(12345).equals("12345");
}

(:test)
function testStepsIconColorGreenAtGoal(logger as Test.Logger) as Boolean {
    return Readouts.stepsIconColor(10000, 10000) == Graphics.COLOR_GREEN
        && Readouts.stepsIconColor(10001, 10000) == Graphics.COLOR_GREEN
        && Readouts.stepsIconColor(9999, 10000) == Graphics.COLOR_WHITE;
}

(:test)
function testStepsIconColorWhiteWhenDataMissing(logger as Test.Logger) as Boolean {
    return Readouts.stepsIconColor(null, 10000) == Graphics.COLOR_WHITE
        && Readouts.stepsIconColor(5000, null) == Graphics.COLOR_WHITE;
}

(:test)
function testBatteryTextRoundsAndAppendsPercent(logger as Test.Logger) as Boolean {
    return Readouts.batteryText(76.4).equals("76%") && Readouts.batteryText(76.6).equals("77%");
}

// The watch reports Body Battery as a Float; shown raw it read "85.000000".
(:test)
function testBodyBatteryLevelRoundsFloatToWholeNumber(logger as Test.Logger) as Boolean {
    return Readouts.formatOrDash(Readouts.bodyBatteryLevel(85.0)).equals("85")
        && Readouts.bodyBatteryLevel(84.6) == 85
        && Readouts.bodyBatteryLevel(84.4) == 84
        && Readouts.bodyBatteryLevel(0.0) == 0
        && Readouts.bodyBatteryLevel(100.0) == 100;
}

(:test)
function testBodyBatteryLevelKeepsMissingDataNull(logger as Test.Logger) as Boolean {
    return Readouts.bodyBatteryLevel(null) == null;
}

(:test)
function testEmptyReadoutIsNull(logger as Test.Logger) as Boolean {
    return Readouts.get(Readouts.EMPTY) == null;
}

(:test)
function testChosenTemperatureDefaultsToFeelsLike(logger as Test.Logger) as Boolean {
    return Readouts.chosenTemperature(15, 18, Readouts.TEMP_FEELS_LIKE) == 15
        && Readouts.chosenTemperature(15, 18, Readouts.TEMP_ACTUAL) == 18;
}

// docs/tickets/08's own acceptance scenario: feels-like 15C / actual 18C.
(:test)
function testTemperatureTextFromTicketScenario(logger as Test.Logger) as Boolean {
    var feelsLike = Readouts.chosenTemperature(15, 18, Readouts.TEMP_FEELS_LIKE);
    var actual = Readouts.chosenTemperature(15, 18, Readouts.TEMP_ACTUAL);
    return Readouts.temperatureText(feelsLike, System.UNIT_METRIC).equals("15°")
        && Readouts.temperatureText(actual, System.UNIT_METRIC).equals("18°")
        && Readouts.temperatureText(actual, System.UNIT_STATUTE).equals("64°");
}

(:test)
function testTemperatureTextShowsDashWhenMissing(logger as Test.Logger) as Boolean {
    return Readouts.temperatureText(null, System.UNIT_METRIC).equals("--");
}

(:test)
function testWeatherIconKindMapsCommonConditions(logger as Test.Logger) as Boolean {
    return Readouts.weatherIconKind(Weather.CONDITION_RAIN) == Icons.WEATHER_ICON_RAIN
        && Readouts.weatherIconKind(Weather.CONDITION_SNOW) == Icons.WEATHER_ICON_SNOW
        && Readouts.weatherIconKind(Weather.CONDITION_CLEAR) == Icons.WEATHER_ICON_CLEAR
        && Readouts.weatherIconKind(Weather.CONDITION_THUNDERSTORMS) == Icons.WEATHER_ICON_THUNDER
        && Readouts.weatherIconKind(Weather.CONDITION_FOG) == Icons.WEATHER_ICON_FOG
        && Readouts.weatherIconKind(Weather.CONDITION_PARTLY_CLOUDY) == Icons.WEATHER_ICON_PARTLY_CLOUDY
        && Readouts.weatherIconKind(Weather.CONDITION_CLOUDY) == Icons.WEATHER_ICON_CLOUDY;
}

(:test)
function testWeatherIconKindDefaultsToCloudyForUnknown(logger as Test.Logger) as Boolean {
    return Readouts.weatherIconKind(Weather.CONDITION_UNKNOWN) == Icons.WEATHER_ICON_CLOUDY
        && Readouts.weatherIconKind(null) == Icons.WEATHER_ICON_CLOUDY;
}

(:test)
function testChooseNextSunEventBeforeSunrise(logger as Test.Logger) as Boolean {
    var event = Readouts.chooseNextSunEvent(
        new Time.Moment(1000), new Time.Moment(2000), new Time.Moment(3000), new Time.Moment(4000)
    );
    return (event.get(:isRise) as Boolean) == true && (event.get(:moment) as Time.Moment).value() == 2000;
}

(:test)
function testChooseNextSunEventBetweenSunriseAndSunset(logger as Test.Logger) as Boolean {
    var event = Readouts.chooseNextSunEvent(
        new Time.Moment(2500), new Time.Moment(2000), new Time.Moment(3000), new Time.Moment(4000)
    );
    return (event.get(:isRise) as Boolean) == false && (event.get(:moment) as Time.Moment).value() == 3000;
}

(:test)
function testChooseNextSunEventAfterSunsetFallsToTomorrow(logger as Test.Logger) as Boolean {
    var event = Readouts.chooseNextSunEvent(
        new Time.Moment(3500), new Time.Moment(2000), new Time.Moment(3000), new Time.Moment(4000)
    );
    return (event.get(:isRise) as Boolean) == true && (event.get(:moment) as Time.Moment).value() == 4000;
}

(:test)
function testChooseNextSunEventNullWhenTodayDataMissing(logger as Test.Logger) as Boolean {
    var now = new Time.Moment(1000);
    return Readouts.chooseNextSunEvent(now, null, new Time.Moment(3000), new Time.Moment(4000)) == null
        && Readouts.chooseNextSunEvent(now, new Time.Moment(2000), null, new Time.Moment(4000)) == null;
}

(:test)
function testChooseNextSunEventNullWhenTomorrowMissingAfterSunset(logger as Test.Logger) as Boolean {
    var now = new Time.Moment(3500);
    return Readouts.chooseNextSunEvent(now, new Time.Moment(2000), new Time.Moment(3000), null) == null;
}

(:test)
function testFormatClock24Hour(logger as Test.Logger) as Boolean {
    return Readouts.formatClock(6, 42, true).equals("06:42") && Readouts.formatClock(21, 0, true).equals("21:00");
}

(:test)
function testFormatClock12Hour(logger as Test.Logger) as Boolean {
    return Readouts.formatClock(6, 42, false).equals("6:42")
        && Readouts.formatClock(0, 5, false).equals("12:05")
        && Readouts.formatClock(13, 5, false).equals("1:05");
}
