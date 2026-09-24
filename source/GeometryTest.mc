import Toybox.Lang;
import Toybox.Test;

(:test)
function testMinuteDegZeroIsNineOClock(logger as Test.Logger) as Boolean {
    return Geometry.minuteDeg(0) == 180.0;
}

(:test)
function testMinuteDegThirtyIsTwelveOClock(logger as Test.Logger) as Boolean {
    return Geometry.minuteDeg(30) == 90.0;
}

(:test)
function testMinuteDegSixtyIsThreeOClock(logger as Test.Logger) as Boolean {
    return Geometry.minuteDeg(60) == 0.0;
}

(:test)
function testPolarAtZeroDegreesIsRightOfCenter(logger as Test.Logger) as Boolean {
    var p = Geometry.polar(0.0, 10.0);
    return p[0] == Screen.cx + 10.0 && p[1] == Screen.cy;
}

(:test)
function testPolarAtNinetyDegreesIsAboveCenter(logger as Test.Logger) as Boolean {
    var p = Geometry.polar(90.0, 10.0);
    return (p[0] - Screen.cx).abs() < 0.001 && p[1] == Screen.cy - 10.0;
}
