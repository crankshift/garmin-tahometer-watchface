import Toybox.Lang;

// The always-on view: the dimmed face an AMOLED watch shows while it sleeps, redrawn once a minute
// (docs/specs/multi-device.md "AMOLED, always-on"). The Tachometer and the Fuel Gauge draw their
// parts in their drawAlwaysOn. The Gear and the Slots draw as they do awake, with the always-on
// font and colors passed in. The view puts them together.
module AlwaysOn {
    // Pure: true when the always-on view replaces the awake face. MIP watches keep the awake face
    // while they sleep.
    function isActive(amoled as Boolean, awake as Boolean) as Boolean {
        return amoled && !awake;
    }
}
