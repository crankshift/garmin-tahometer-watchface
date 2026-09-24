import Toybox.Lang;
import Toybox.Test;

(:test)
function testGlowLayoutAtV1ScaleEqualsTheSpecConstants(logger as Test.Logger) as Boolean {
    // Each of the three strokes goes 5, 3.5 and 2 px past the shape on both sides (widest first).
    var l = new Glow.Layout(130.0f);
    return l.reach.size() == 3 && l.reach[0] == 5.0 && l.reach[1] == 3.5 && l.reach[2] == 2.0;
}

(:test)
function testGlowLayoutAt454ScalesByTheScreenWidthOver260(logger as Test.Logger) as Boolean {
    var l = new Glow.Layout(227.0f);
    var s = 454.0 / 260.0;
    return nearly(l.reach[0], 5 * s) && nearly(l.reach[1], 3.5 * s) && nearly(l.reach[2], 2 * s);
}

(:test)
function testGlowAlphasAreTenSixteenAndTwentySixPercent(logger as Test.Logger) as Boolean {
    var a = Glow.ALPHAS;
    return a.size() == 3 && a[0] == 26 && a[1] == 41 && a[2] == 66;
}

(:test)
function testGlowStrokesGetNarrowerAndMoreOpaque(logger as Test.Logger) as Boolean {
    var a = Glow.ALPHAS;
    var l = new Glow.Layout(130.0f);
    return a[0] < a[1] && a[1] < a[2] && l.reach[0] > l.reach[1] && l.reach[1] > l.reach[2];
}

(:test)
function testGlowPassWidthAddsTheExtraOnBothSides(logger as Test.Logger) as Boolean {
    Glow.fit(130.0f);
    // An 8 px band, glowing 5 px each way at the widest pass.
    return Glow.passWidth(8, 0) == 18.0 && Glow.passWidth(8, 1) == 15.0 && Glow.passWidth(8, 2) == 12.0
        && Glow.passWidth(3, 2) == 7.0;
}

(:test)
function testGlowPassWidthScalesWithTheFit(logger as Test.Logger) as Boolean {
    Glow.fit(227.0f);
    var wide = Glow.passWidth(14, 0);
    Glow.fit(130.0f);
    return nearly(wide, 14 + 2 * 5 * 454.0 / 260.0);
}

(:test)
function testGlowChannelsSplitsAnRgbColor(logger as Test.Logger) as Boolean {
    var amber = Glow.channels(0xFFAA00);
    var mixed = Glow.channels(0x010203);
    return amber[0] == 255 && amber[1] == 170 && amber[2] == 0
        && mixed[0] == 1 && mixed[1] == 2 && mixed[2] == 3;
}
