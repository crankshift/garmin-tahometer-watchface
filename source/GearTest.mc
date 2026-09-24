import Toybox.Lang;
import Toybox.Test;

(:test)
function testGearTextMidnight24Hour(logger as Test.Logger) as Boolean {
    return Gear.gearText(0, true).equals("0");
}

(:test)
function testGearTextMidnight12Hour(logger as Test.Logger) as Boolean {
    return Gear.gearText(0, false).equals("12");
}

(:test)
function testGearTextElevenIsUnchangedInBothModes(logger as Test.Logger) as Boolean {
    return Gear.gearText(11, true).equals("11") && Gear.gearText(11, false).equals("11");
}

(:test)
function testGearTextNoonTwelveHourStaysTwelve(logger as Test.Logger) as Boolean {
    return Gear.gearText(12, true).equals("12") && Gear.gearText(12, false).equals("12");
}

(:test)
function testGearTextThirteenDropsToOneInTwelveHour(logger as Test.Logger) as Boolean {
    return Gear.gearText(13, true).equals("13") && Gear.gearText(13, false).equals("1");
}

(:test)
function testGearTextTwentyThreeIsElevenInTwelveHour(logger as Test.Logger) as Boolean {
    return Gear.gearText(23, true).equals("23") && Gear.gearText(23, false).equals("11");
}

(:test)
function testIsAMBeforeNoon(logger as Test.Logger) as Boolean {
    return Gear.isAM(0) && Gear.isAM(11) && !Gear.isAM(12) && !Gear.isAM(23);
}

(:test)
function testGearLayoutAtV1ScaleEqualsTheV1Constants(logger as Test.Logger) as Boolean {
    var l = new Gear.Layout(130.0f);
    return l.centerY == 94.0 && l.ampmGap == 9.0;
}

(:test)
function testGearLayoutAt454ScalesByTheScreenWidthOver260(logger as Test.Logger) as Boolean {
    var l = new Gear.Layout(227.0f);
    var s = 454.0 / 260.0;
    return nearly(l.centerY, 94 * s) && nearly(l.ampmGap, 9 * s);
}
