import Toybox.Lang;
import Toybox.Math;

// Ported from prototype/index.html's minuteDeg and polar helpers.
module Geometry {
    // Minute or second to Garmin degrees (counter-clockwise from 3 o'clock), as Dc.drawArc
    // expects. 0 sits at 9 o'clock, 30 at 12 o'clock, 60 at 3 o'clock.
    function minuteDeg(value as Numeric) as Float {
        return 180.0 - value * 3.0;
    }

    // Polar to cartesian around the face center.
    function polar(deg as Float, r as Float) as Array<Float> {
        var rad = Math.toRadians(deg);
        return [Constants.CX + r * Math.cos(rad), Constants.CY - r * Math.sin(rad)] as Array<Float>;
    }
}
