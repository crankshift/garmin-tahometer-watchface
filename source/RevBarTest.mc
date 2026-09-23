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
    // Each segment spans about 3 degrees at radius R_REV; the clip box should be small,
    // not, say, half the screen.
    var bounds = RevBar.segmentClipBounds(0);
    return bounds[2] > 0 && bounds[2] < 20 && bounds[3] > 0 && bounds[3] < 20;
}
