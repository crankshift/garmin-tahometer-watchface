import Toybox.Lang;
import Toybox.Graphics;

// Ported from prototype/index.html's drawSlot. Layout only; Readouts.mc supplies the content.
module Slots {
    const ICON_SIZE = 14.0;
    const GAP = 5.0;

    const LEFT = [Constants.CX - 70, Constants.CY + 38];
    const CENTER = [Constants.CX, Constants.CY + 38];
    const RIGHT = [Constants.CX + 70, Constants.CY + 38];
    const BOTTOM = [Constants.CX, Constants.CY + 84];

    // Icon (or head text) 11 px above the Slot point, value 10 px below.
    function drawStacked(
        dc as Graphics.Dc,
        pos as Array<Float>,
        content as ReadoutContent?,
        headFont as Graphics.FontDefinition,
        valueFont as Graphics.FontDefinition
    ) as Void {
        if (content == null) {
            return;
        }
        var x = pos[0];
        var y = pos[1];
        if (content.head != null) {
            dc.setColor(Graphics.COLOR_LT_GRAY, Graphics.COLOR_TRANSPARENT);
            dc.drawText(x, y - 11, headFont, content.head, Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER);
        } else {
            Readouts.drawIcon(dc, content.kind, x, y - 11, content.iconColor, content.extra);
        }
        dc.setColor(content.textColor, Graphics.COLOR_TRANSPARENT);
        dc.drawText(x, y + 10, valueFont, content.text, Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER);
    }

    // Icon, a 5 px gap, then the value, centered as one group.
    function drawInline(
        dc as Graphics.Dc,
        pos as Array<Float>,
        content as ReadoutContent?,
        headFont as Graphics.FontDefinition,
        valueFont as Graphics.FontDefinition
    ) as Void {
        if (content == null) {
            return;
        }
        var x = pos[0];
        var y = pos[1];
        var lead = content.head != null ? dc.getTextWidthInPixels(content.head, headFont) : ICON_SIZE;
        var valueWidth = dc.getTextWidthInPixels(content.text, valueFont);
        var x0 = x - (lead + GAP + valueWidth) / 2.0;
        if (content.head != null) {
            dc.setColor(Graphics.COLOR_LT_GRAY, Graphics.COLOR_TRANSPARENT);
            dc.drawText(x0, y, headFont, content.head, Graphics.TEXT_JUSTIFY_LEFT | Graphics.TEXT_JUSTIFY_VCENTER);
        } else {
            Readouts.drawIcon(dc, content.kind, x0 + ICON_SIZE / 2.0, y, content.iconColor, content.extra);
        }
        dc.setColor(content.textColor, Graphics.COLOR_TRANSPARENT);
        dc.drawText(x0 + lead + GAP, y, valueFont, content.text, Graphics.TEXT_JUSTIFY_LEFT | Graphics.TEXT_JUSTIFY_VCENTER);
    }

    function draw(
        dc as Graphics.Dc,
        leftKind as Number,
        centerKind as Number,
        rightKind as Number,
        bottomKind as Number,
        headFont as Graphics.FontDefinition,
        valueFont as Graphics.FontDefinition
    ) as Void {
        drawStacked(dc, LEFT, Readouts.get(leftKind), headFont, valueFont);
        drawStacked(dc, CENTER, Readouts.get(centerKind), headFont, valueFont);
        drawStacked(dc, RIGHT, Readouts.get(rightKind), headFont, valueFont);
        drawInline(dc, BOTTOM, Readouts.get(bottomKind), headFont, valueFont);
    }
}
