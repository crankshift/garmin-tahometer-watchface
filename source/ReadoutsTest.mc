import Toybox.Lang;
import Toybox.Graphics;
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

(:test)
function testEmptyReadoutIsNull(logger as Test.Logger) as Boolean {
    return Readouts.get(Readouts.EMPTY) == null;
}
