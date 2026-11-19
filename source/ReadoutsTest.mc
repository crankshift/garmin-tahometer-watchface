import Toybox.Lang;
import Toybox.Graphics;
import Toybox.System;
import Toybox.Weather;
import Toybox.Position;
import Toybox.Time;
import Toybox.Test;

// Gregorian's day_of_week number, 1 for Sunday, gives the abbreviation from the face's own tables, not
// the watch's localized name: SmallFont only has these letters, so a name like "Пт" drew as boxes.
(:test)
function testDateHeadIsEnglishByDefault(logger as Test.Logger) as Boolean {
    return Readouts.dateHead(1, System.LANGUAGE_ENG).equals("SUN")
        && Readouts.dateHead(4, System.LANGUAGE_ENG).equals("WED")
        && Readouts.dateHead(7, System.LANGUAGE_ENG).equals("SAT");
}

(:test)
function testDateHeadIsEnglishForALanguageWithoutItsOwnTable(logger as Test.Logger) as Boolean {
    return Readouts.dateHead(6, System.LANGUAGE_DEU).equals("FRI");
}

(:test)
function testDateHeadIsPolishOnAPolishWatch(logger as Test.Logger) as Boolean {
    return Readouts.dateHead(1, System.LANGUAGE_POL).equals("NDZ")
        && Readouts.dateHead(4, System.LANGUAGE_POL).equals("ŚR")
        && Readouts.dateHead(5, System.LANGUAGE_POL).equals("CZW");
}

(:test)
function testDateHeadIsUkrainianOnAUkrainianWatch(logger as Test.Logger) as Boolean {
    return Readouts.dateHead(1, System.LANGUAGE_UKR).equals("НД")
        && Readouts.dateHead(6, System.LANGUAGE_UKR).equals("ПТ");
}

(:test)
function testDateHeadIsRussianOnARussianWatch(logger as Test.Logger) as Boolean {
    return Readouts.dateHead(1, System.LANGUAGE_RUS).equals("ВС")
        && Readouts.dateHead(4, System.LANGUAGE_RUS).equals("СР");
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

// A Location in degrees, for the sun location tests.
(:debug)
function sunTestLocation(latitude as Float, longitude as Float) as Position.Location {
    return new Position.Location({ :latitude => latitude, :longitude => longitude, :format => :degrees });
}

// Ticket 16: phone weather first, then the watch's last GPS fix, then the saved last known location.
(:test)
function testPickSunLocationPrefersWeatherThenGpsThenSaved(logger as Test.Logger) as Boolean {
    var weather = sunTestLocation(52.0, 21.0);
    var gps = sunTestLocation(53.0, 21.0);
    var saved = sunTestLocation(54.0, 21.0);
    return Readouts.pickSunLocation(weather, gps, saved) == weather
        && Readouts.pickSunLocation(weather, null, saved) == weather
        && Readouts.pickSunLocation(weather, gps, null) == weather
        && Readouts.pickSunLocation(null, gps, saved) == gps
        && Readouts.pickSunLocation(null, null, saved) == saved;
}

// The reporter's case: no phone weather, a fresh GPS fix, nothing saved yet.
(:test)
function testPickSunLocationUsesGpsWhenItIsTheOnlyOne(logger as Test.Logger) as Boolean {
    var gps = sunTestLocation(53.0, 21.0);
    return Readouts.pickSunLocation(null, gps, null) == gps;
}

(:test)
function testPickSunLocationNullWhenNoSourceHasOne(logger as Test.Logger) as Boolean {
    return Readouts.pickSunLocation(null, null, null) == null;
}

// Some watches report a missing GPS fix as 180°, 180° instead of null. It must not reach the sun
// calls or overwrite a good saved location.
(:test)
function testUsableSunLocationDropsImpossibleCoordinates(logger as Test.Logger) as Boolean {
    var good = sunTestLocation(52.23, 21.01);
    return Readouts.usableSunLocation(good) == good
        && Readouts.usableSunLocation(sunTestLocation(180.0, 180.0)) == null
        && Readouts.usableSunLocation(null) == null;
}

// The saved location is rewritten only when the live one is more than 0.01° away in latitude or
// longitude, so flash isn't written every minute.
(:test)
function testShouldSaveSunLocationWhenNothingIsSaved(logger as Test.Logger) as Boolean {
    return Readouts.shouldSaveSunLocation(null, [52.23, 21.01]);
}

(:test)
function testShouldNotSaveSunLocationThatMovedUnderAHundredthOfADegree(logger as Test.Logger) as Boolean {
    return !Readouts.shouldSaveSunLocation([52.23, 21.01], [52.235, 21.005]);
}

(:test)
function testShouldSaveSunLocationThatMovedInLatitudeOrLongitude(logger as Test.Logger) as Boolean {
    return Readouts.shouldSaveSunLocation([52.23, 21.01], [52.25, 21.01])
        && Readouts.shouldSaveSunLocation([52.23, 21.01], [52.23, 20.99]);
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
