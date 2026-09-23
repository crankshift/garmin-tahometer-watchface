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
