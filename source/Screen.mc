import Toybox.Lang;
import Toybox.Math;

// The screen the face is drawn on, and the scale factor between it and the 260 px screen every
// fixed pixel value was written for (docs/specs/multi-device.md "Scaling"). The view calls fit
// once in onLayout; a module that needs a scaled value builds it from Screen.radius, or from
// Screen.scale where it has no layout of its own.
module Screen {
    // Half the width of the 260 px screen.
    const V1_RADIUS = 130.0f;

    // Start as the 260 px screen, so code that runs before onLayout (and the unit tests) sees v1.
    var cx as Float = V1_RADIUS;
    var cy as Float = V1_RADIUS;
    var radius as Float = V1_RADIUS;
    var scale as Float = 1.0f;

    // True on AMOLED watches, which get the awake extras and the always-on view.
    var amoled as Boolean = false;

    // Round screens are as tall as they are wide. `amoled` comes from
    // DeviceSettings.requiresBurnInProtection.
    function fit(width as Number, isAmoled as Boolean) as Void {
        amoled = isAmoled;
        radius = width / 2.0f;
        cx = radius;
        cy = radius;
        scale = scaleFor(radius);
    }

    // Pure: the factor a screen of the given radius scales the v1 pixel values by.
    function scaleFor(radius as Float) as Float {
        return radius / V1_RADIUS;
    }

    // Pure: a v1 pen width at scale `s`, rounded to whole pixels and never thinner than 1 px.
    function penWidth(v1 as Numeric, s as Float) as Number {
        var width = Math.round(v1 * s).toNumber();
        return width < 1 ? 1 : width;
    }

    // Pure: like penWidth, but not rounded, for the icon strokes that are fractional in v1 (1.5 px).
    // At 260 px it returns the v1 value, so those icons draw as they always did.
    function strokeWidth(v1 as Numeric, s as Float) as Float {
        var width = v1 * s;
        return width < 1.0 ? 1.0 : width.toFloat();
    }
}
