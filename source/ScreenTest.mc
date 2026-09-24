import Toybox.Lang;
import Toybox.Test;

// Tolerance for scaled Float values: the watch computes in 32-bit floats.
(:debug)
function nearly(actual as Numeric, expected as Numeric) as Boolean {
    return (actual - expected).abs() < 0.01;
}

(:test)
function testScaleForV1ScreenIsOne(logger as Test.Logger) as Boolean {
    return Screen.scaleFor(130.0f) == 1.0;
}

(:test)
function testScaleForFenix7SIsBelowOne(logger as Test.Logger) as Boolean {
    return nearly(Screen.scaleFor(120.0f), 240.0 / 260.0);
}

(:test)
function testScaleForFr965IsScreenWidthOver260(logger as Test.Logger) as Boolean {
    return nearly(Screen.scaleFor(227.0f), 454.0 / 260.0);
}

(:test)
function testPenWidthAtV1ScaleIsUnchanged(logger as Test.Logger) as Boolean {
    return Screen.penWidth(8, 1.0) == 8
        && Screen.penWidth(3, 1.0) == 3
        && Screen.penWidth(2, 1.0) == 2
        && Screen.penWidth(1, 1.0) == 1;
}

(:test)
function testPenWidthScalesAndRoundsToWholePixels(logger as Test.Logger) as Boolean {
    var s = 454.0 / 260.0; // 1.746
    return Screen.penWidth(8, s) == 14   // 13.97
        && Screen.penWidth(3, s) == 5    // 5.24
        && Screen.penWidth(2, s) == 3;   // 3.49
}

(:test)
function testPenWidthNeverDropsBelowOnePixel(logger as Test.Logger) as Boolean {
    var s = 240.0 / 260.0; // 0.923
    return Screen.penWidth(1, s) == 1 && Screen.penWidth(0.5, s) == 1;
}

(:test)
function testFitSetsCenterRadiusAndScaleFromScreenWidth(logger as Test.Logger) as Boolean {
    Screen.fit(454);
    var ok = Screen.radius == 227.0 && Screen.cx == 227.0 && Screen.cy == 227.0 && nearly(Screen.scale, 454.0 / 260.0);
    Screen.fit(260);
    return ok && Screen.radius == 130.0 && Screen.scale == 1.0;
}

(:test)
function testStrokeWidthAtV1ScaleIsUnchangedEvenWhenFractional(logger as Test.Logger) as Boolean {
    // Icon strokes are 1.5 px in v1; rounding them would change the 260 px face.
    return Screen.strokeWidth(1.5, 1.0) == 1.5 && Screen.strokeWidth(2, 1.0) == 2.0 && Screen.strokeWidth(1, 1.0) == 1.0;
}

(:test)
function testStrokeWidthScalesWithoutRounding(logger as Test.Logger) as Boolean {
    return nearly(Screen.strokeWidth(1.5, 454.0 / 260.0), 1.5 * 454.0 / 260.0);
}

(:test)
function testStrokeWidthNeverDropsBelowOnePixel(logger as Test.Logger) as Boolean {
    return Screen.strokeWidth(1, 240.0 / 260.0) == 1.0;
}
