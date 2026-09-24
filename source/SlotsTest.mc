import Toybox.Lang;
import Toybox.Test;

(:test)
function testSlotsLayoutAtV1ScaleEqualsTheV1Constants(logger as Test.Logger) as Boolean {
    var l = new Slots.Layout(130.0f);
    return l.iconSize == 14.0 && l.gap == 5.0
        && l.stackedIconOffset == 11.0 && l.stackedValueOffset == 10.0
        && l.left[0] == 60.0 && l.left[1] == 168.0
        && l.center[0] == 130.0 && l.center[1] == 168.0
        && l.right[0] == 200.0 && l.right[1] == 168.0
        && l.bottom[0] == 130.0 && l.bottom[1] == 214.0;
}

(:test)
function testSlotsLayoutAt454ScalesByTheScreenWidthOver260(logger as Test.Logger) as Boolean {
    var l = new Slots.Layout(227.0f);
    var s = 454.0 / 260.0;
    return nearly(l.iconSize, 14 * s) && nearly(l.gap, 5 * s)
        && nearly(l.stackedIconOffset, 11 * s) && nearly(l.stackedValueOffset, 10 * s)
        && nearly(l.left[0], 60 * s) && nearly(l.left[1], 168 * s)
        && nearly(l.center[0], 130 * s) && nearly(l.center[1], 168 * s)
        && nearly(l.right[0], 200 * s) && nearly(l.right[1], 168 * s)
        && nearly(l.bottom[0], 130 * s) && nearly(l.bottom[1], 214 * s);
}
