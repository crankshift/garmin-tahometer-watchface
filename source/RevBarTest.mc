import Toybox.Lang;
import Toybox.Graphics;
import Toybox.Test;

(:test)
function testRevBarSegmentColorRedlineIsLastTenSeconds(logger as Test.Logger) as Boolean {
    return RevBar.segmentColor(49) == Graphics.COLOR_WHITE
        && RevBar.segmentColor(50) == Graphics.COLOR_RED
        && RevBar.segmentColor(59) == Graphics.COLOR_RED;
}

(:test)
function testRevBarSegmentClipBoundsIsASmallBox(logger as Test.Logger) as Boolean {
    // Each segment spans about 3 degrees at radius RevBar.layout.rRev; the clip box should be small,
    // not, say, half the screen.
    var bounds = RevBar.segmentClipBounds(0);
    return bounds[2] > 0 && bounds[2] < 20 && bounds[3] > 0 && bounds[3] < 20;
}

(:test)
function testRevBarLayoutAtV1ScaleEqualsTheV1Constants(logger as Test.Logger) as Boolean {
    var l = new RevBar.Layout(130.0f);
    return l.rRev == 80.0 && l.penWidth == 3;
}

(:test)
function testRevBarLayoutAt454ScalesByTheScreenWidthOver260(logger as Test.Logger) as Boolean {
    var l = new RevBar.Layout(227.0f);
    return nearly(l.rRev, 80 * 454.0 / 260.0) && l.penWidth == 5;
}

(:test)
function testRevBarClipBoxGrowsWithTheScreen(logger as Test.Logger) as Boolean {
    var small = RevBar.segmentClipBounds(10);
    Screen.fit(454);
    RevBar.fit(Screen.radius);
    var large = RevBar.segmentClipBounds(10);
    Screen.fit(260);
    RevBar.fit(Screen.radius);
    // About 454 / 260 times the 260 box; the pen width rounds to whole pixels, so allow 4 px.
    var scale = 454.0 / 260.0;
    return (large[2] - small[2] * scale).abs() < 4 && (large[3] - small[3] * scale).abs() < 4;
}
