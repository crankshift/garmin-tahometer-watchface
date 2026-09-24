import Toybox.Lang;
import Toybox.Test;

(:test)
function testLerpColorEndpointsAreTheTwoColors(logger as Test.Logger) as Boolean {
    return Redline.lerpColor(0x220000, 0x770000, 0.0) == 0x220000
        && Redline.lerpColor(0x220000, 0x770000, 1.0) == 0x770000;
}

(:test)
function testLerpColorBlendsEachChannelSeparately(logger as Test.Logger) as Boolean {
    return Redline.lerpColor(0x102030, 0x304050, 0.5) == 0x203040;
}

(:test)
function testUnlitGradientGetsBrighterFromMinute50To60(logger as Test.Logger) as Boolean {
    var first = Redline.halfMinuteColor(50.0, false);
    var middle = Redline.halfMinuteColor(55.0, false);
    var last = Redline.halfMinuteColor(59.5, false);
    // Dark red only: red channel rises, green and blue stay zero.
    return first == 0x240000 && middle == 0x4F0000
        && (last >> 16) > (middle >> 16) && (last & 0xFFFF) == 0;
}

(:test)
function testLitGradientRunsFromDarkRedToOrangeRed(logger as Test.Logger) as Boolean {
    var first = Redline.halfMinuteColor(50.0, true);
    var middle = Redline.halfMinuteColor(55.0, true);
    var last = Redline.halfMinuteColor(59.5, true);
    // Red rises from 0xAA toward 0xFF, and green from 0 toward 0x33.
    return first == 0xAC0100 && middle == 0xD71B00
        && (last >> 16) > 0xF8 && ((last >> 8) & 0xFF) > 0x30 && (last & 0xFF) == 0;
}

(:test)
function testLitGradientIsBrighterThanUnlitAtEveryMinute(logger as Test.Logger) as Boolean {
    for (var m = 50.0; m < 60.0; m += 0.5) {
        if ((Redline.halfMinuteColor(m, true) >> 16) <= (Redline.halfMinuteColor(m, false) >> 16)) {
            return false;
        }
    }
    return true;
}
