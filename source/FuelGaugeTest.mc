import Toybox.Lang;
import Toybox.Graphics;
import Toybox.Test;

(:test)
function testFuelGaugeLitSegmentsFromTicketScenarios(logger as Test.Logger) as Boolean {
    return FuelGauge.litSegments(76) == 8
        && FuelGauge.litSegments(18) == 2
        && FuelGauge.litSegments(9) == 1
        && FuelGauge.litSegments(4) == 0;
}

(:test)
function testFuelGaugeLitSegmentsRoundsToNearest(logger as Test.Logger) as Boolean {
    return FuelGauge.litSegments(100) == 10 && FuelGauge.litSegments(0) == 0;
}

(:test)
function testLowFuelLampColorThresholds(logger as Test.Logger) as Boolean {
    return FuelGauge.lowFuelLampColor(76) == Graphics.COLOR_DK_GRAY
        && FuelGauge.lowFuelLampColor(18) == Graphics.COLOR_YELLOW
        && FuelGauge.lowFuelLampColor(9) == Graphics.COLOR_RED
        && FuelGauge.lowFuelLampColor(4) == Graphics.COLOR_RED;
}

(:test)
function testLowFuelLampColorBoundaries(logger as Test.Logger) as Boolean {
    return FuelGauge.lowFuelLampColor(21) == Graphics.COLOR_DK_GRAY
        && FuelGauge.lowFuelLampColor(20) == Graphics.COLOR_YELLOW
        && FuelGauge.lowFuelLampColor(11) == Graphics.COLOR_YELLOW
        && FuelGauge.lowFuelLampColor(10) == Graphics.COLOR_RED;
}

(:test)
function testFuelGaugeLayoutAtV1ScaleEqualsTheV1Constants(logger as Test.Logger) as Boolean {
    var l = new FuelGauge.Layout(130.0f);
    return l.rBand == 124.0 && l.bandW == 8 && l.iconR == 114.0;
}

(:test)
function testFuelGaugeLayoutAt454ScalesByTheScreenWidthOver260(logger as Test.Logger) as Boolean {
    var l = new FuelGauge.Layout(227.0f);
    var s = 454.0 / 260.0;
    return nearly(l.rBand, 124 * s) && l.bandW == 14 && nearly(l.iconR, 114 * s);
}
