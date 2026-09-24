import Toybox.Lang;
import Toybox.Test;

(:test)
function testAlwaysOnViewShowsOnlyOnAmoledWhileAsleep(logger as Test.Logger) as Boolean {
    return AlwaysOn.isActive(true, false)
        && !AlwaysOn.isActive(true, true)
        && !AlwaysOn.isActive(false, false)
        && !AlwaysOn.isActive(false, true);
}
