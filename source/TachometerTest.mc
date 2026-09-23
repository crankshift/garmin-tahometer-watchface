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
