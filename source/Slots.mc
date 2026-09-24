import Toybox.Lang;
import Toybox.Graphics;

// Ported from prototype/index.html's drawSlot. Layout only; Readouts.mc supplies the content.
module Slots {
    // Written for the 260 px screen and scaled by the screen's radius (docs/specs/multi-device.md
    // "Scaling"). Built once in fit.
    class Layout {
        var iconSize as Float;
        var gap as Float;
        var stackedIconOffset as Float;  // icon (or head text) above the Slot point
        var stackedValueOffset as Float; // value below it
        var left as Array<Float>;
        var center as Array<Float>;
        var right as Array<Float>;
        var bottom as Array<Float>;

        // Round screens: the center is at the radius, in x and in y.
        function initialize(radius as Float) {
            var s = Screen.scaleFor(radius);
            iconSize = 14.0 * s;
            gap = 5.0 * s;
            stackedIconOffset = 11.0 * s;
            stackedValueOffset = 10.0 * s;
            left = [radius - 70 * s, radius + 38 * s] as Array<Float>;
            center = [radius, radius + 38 * s] as Array<Float>;
            right = [radius + 70 * s, radius + 38 * s] as Array<Float>;
            bottom = [radius, radius + 84 * s] as Array<Float>;
        }
    }

    // Starts as the 260 px layout; the view calls fit from onLayout.
    var layout as Layout = new Layout(Screen.V1_RADIUS);

    function fit(radius as Float) as Void {
        layout = new Layout(radius);
    }

    // Pure: the color of a Slot's value. The always-on view dims a white one to light grey and leaves
    // the others (the dimmed Notifications count, say) alone. Icons keep their usual colors.
    function valueColor(color as Graphics.ColorType, alwaysOn as Boolean) as Graphics.ColorType {
        return alwaysOn && color == Graphics.COLOR_WHITE ? Graphics.COLOR_LT_GRAY : color;
    }

    // Icon (or head text) 11 px above the Slot point, value 10 px below (at 260 px).
    function drawStacked(
        dc as Graphics.Dc,
        pos as Array<Float>,
        content as ReadoutContent?,
        headFont as Graphics.FontDefinition,
        valueFont as Graphics.FontDefinition,
        alwaysOn as Boolean
    ) as Void {
        if (content == null) {
            return;
        }
        var x = pos[0];
        var y = pos[1];
        if (content.head != null) {
            dc.setColor(Graphics.COLOR_LT_GRAY, Graphics.COLOR_TRANSPARENT);
            dc.drawText(x, y - layout.stackedIconOffset, headFont, content.head, Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER);
        } else {
            Readouts.drawIcon(dc, content.kind, x, y - layout.stackedIconOffset, content.iconColor, content.extra);
        }
        dc.setColor(valueColor(content.textColor, alwaysOn), Graphics.COLOR_TRANSPARENT);
        dc.drawText(x, y + layout.stackedValueOffset, valueFont, content.text, Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER);
    }

    // Icon, a 5 px gap (at 260 px), then the value, centered as one group.
    function drawInline(
        dc as Graphics.Dc,
        pos as Array<Float>,
        content as ReadoutContent?,
        headFont as Graphics.FontDefinition,
        valueFont as Graphics.FontDefinition,
        alwaysOn as Boolean
    ) as Void {
        if (content == null) {
            return;
        }
        var x = pos[0];
        var y = pos[1];
        var lead = content.head != null ? dc.getTextWidthInPixels(content.head, headFont) : layout.iconSize;
        var valueWidth = dc.getTextWidthInPixels(content.text, valueFont);
        var x0 = x - (lead + layout.gap + valueWidth) / 2.0;
        if (content.head != null) {
            dc.setColor(Graphics.COLOR_LT_GRAY, Graphics.COLOR_TRANSPARENT);
            dc.drawText(x0, y, headFont, content.head, Graphics.TEXT_JUSTIFY_LEFT | Graphics.TEXT_JUSTIFY_VCENTER);
        } else {
            Readouts.drawIcon(dc, content.kind, x0 + layout.iconSize / 2.0, y, content.iconColor, content.extra);
        }
        dc.setColor(valueColor(content.textColor, alwaysOn), Graphics.COLOR_TRANSPARENT);
        dc.drawText(x0 + lead + layout.gap, y, valueFont, content.text, Graphics.TEXT_JUSTIFY_LEFT | Graphics.TEXT_JUSTIFY_VCENTER);
    }

    function draw(
        dc as Graphics.Dc,
        leftKind as Number,
        centerKind as Number,
        rightKind as Number,
        bottomKind as Number,
        headFont as Graphics.FontDefinition,
        valueFont as Graphics.FontDefinition,
        alwaysOn as Boolean
    ) as Void {
        drawStacked(dc, layout.left, Readouts.get(leftKind), headFont, valueFont, alwaysOn);
        drawStacked(dc, layout.center, Readouts.get(centerKind), headFont, valueFont, alwaysOn);
        drawStacked(dc, layout.right, Readouts.get(rightKind), headFont, valueFont, alwaysOn);
        drawInline(dc, layout.bottom, Readouts.get(bottomKind), headFont, valueFont, alwaysOn);
    }
}
