import Toybox.Lang;
import Toybox.Test;

(:test)
function testTickSpecMajorEveryTenMinutes(logger as Test.Logger) as Boolean {
    var spec = Tachometer.tickSpec(10);
    return spec[0] == 12 && spec[1] == 3;
}

(:test)
function testTickSpecMidEveryFiveMinutes(logger as Test.Logger) as Boolean {
    var spec = Tachometer.tickSpec(25);
    return spec[0] == 8 && spec[1] == 2;
}

(:test)
function testTickSpecMinorEveryMinute(logger as Test.Logger) as Boolean {
    var spec = Tachometer.tickSpec(12);
    return spec[0] == 4 && spec[1] == 1;
}

(:test)
function testTickSpecPrefersMajorOverMinorAtZero(logger as Test.Logger) as Boolean {
    var spec = Tachometer.tickSpec(0);
    return spec[0] == 12 && spec[1] == 3;
}

(:test)
function testIsRedlineAtFiftyAndAbove(logger as Test.Logger) as Boolean {
    return Tachometer.isRedline(50) && Tachometer.isRedline(60) && !Tachometer.isRedline(49);
}

(:test)
function testIsRedlineForNumeralFiveAndSix(logger as Test.Logger) as Boolean {
    // Numerals pass n * 10, so 5 and 6 land in the Redline (docs/tickets/03) and 0-4 don't.
    return Tachometer.isRedline(5 * 10) && Tachometer.isRedline(6 * 10) && !Tachometer.isRedline(4 * 10);
}

(:test)
function testTachometerLayoutAtV1ScaleEqualsTheV1Constants(logger as Test.Logger) as Boolean {
    var l = new Tachometer.Layout(130.0f);
    return l.rBand == 124.0 && l.bandW == 8
        && l.rTick == 119.0 && l.rNum == 96.0
        && l.needleR0 == 84.0 && l.needleR1 == 122.0
        && l.needleHalfWidthBase == 2.5 && l.needleHalfWidthTip == 1.0
        && l.tipInnerR == 111.0 && l.tipPen == 3
        && l.majorTickLength == 12.0 && l.majorTickPen == 3
        && l.midTickLength == 8.0 && l.midTickPen == 2
        && l.minorTickLength == 4.0 && l.minorTickPen == 1;
}

(:test)
function testTachometerLayoutAt454ScalesByTheScreenWidthOver260(logger as Test.Logger) as Boolean {
    var l = new Tachometer.Layout(227.0f);
    var s = 454.0 / 260.0;
    return nearly(l.rBand, 124 * s) && l.bandW == 14
        && nearly(l.rTick, 119 * s) && nearly(l.rNum, 96 * s)
        && nearly(l.needleR0, 84 * s) && nearly(l.needleR1, 122 * s)
        && nearly(l.needleHalfWidthBase, 2.5 * s) && nearly(l.needleHalfWidthTip, 1.0 * s)
        && nearly(l.tipInnerR, 111 * s) && l.tipPen == 5
        && nearly(l.majorTickLength, 12 * s) && l.majorTickPen == 5
        && nearly(l.midTickLength, 8 * s) && l.midTickPen == 3
        && nearly(l.minorTickLength, 4 * s) && l.minorTickPen == 2;
}

(:test)
function testTachometerLayoutKeepsPenWidthsAtOnePixelOrMoreOn240(logger as Test.Logger) as Boolean {
    var l = new Tachometer.Layout(120.0f);
    return l.minorTickPen == 1 && l.midTickPen == 2 && l.majorTickPen == 3;
}
