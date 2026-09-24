# 11: Proportional geometry and per-resolution fonts

Status: open
Depends on: none
Spec: [`docs/specs/multi-device.md`](../specs/multi-device.md), "Scaling"
Prototype reference: the Screen picker, `sizeViews`, and `render` (which scales every coordinate by `px / 260`)

## Goal

The face draws correctly on any round screen size, scaled in proportion to the screen, with bitmap fonts made for each supported resolution. No watches are added here. At 260 px the face must stay pixel-identical to v1.

## Scope

- **Screen geometry from the screen.** `Constants.CX`, `CY` and `R` are fixed at 130 today. Read them from the screen instead (`dc.getWidth() / 2`), and add the scale factor `s = R / 130`.
- **Scale every fixed pixel value by `s`.** Today these are constants written for 260 px:
  - `Tachometer`: `R_BAND`, `BAND_W`, `R_TICK`, `R_NUM`, `NEEDLE_R0`, `NEEDLE_R1`, the needle half-widths, the tick lengths and pen widths, and the Tip.
  - `RevBar`: `R_REV`, `PEN_WIDTH`.
  - `Gear`: `CENTER_Y`, `AMPM_GAP`.
  - `FuelGauge`: `R_BAND`, `BAND_W`, `ICON_R`.
  - `Slots`: `ICON_SIZE`, `GAP`, the four Slot positions, and the offsets between icon and value.
  - `Icons`: every shape (about 14 px) and pen width.

  Radius offsets scale as well: `R - 6` becomes `R - 6 * s`. Angles don't change. Round pen widths to at least 1 px.
- **Where to compute it.** The recommended approach is to compute the scaled values once in `onLayout`, so that `onPartialUpdate` (the Rev Bar in low power) costs no more than it does today. Generating constants per device family at build time through the jungle is also fine, if it turns out simpler. In both cases, 260 must stay identical.
- **Fonts per resolution.** `tools/gen_bitmap_font.py` loops over 240, 260, 280, 360, 390, 416, 454 and 466. Each font's size is `round(v1 size × px / 260)`, from the v1 sizes gear 89, tachometer numeral 24, slot value 20 and small 15. The script writes `resources-round-{px}x{px}/fonts/` (the `fonts.xml`, `.fnt` and `.png` files), and `resources/fonts/` stays the 260 set.
  - Check that `monkeyc` picks up the qualified folders: build for a 240 and a 454 device and confirm the font sizes differ, for example from the resource size in `--build-stats`.
- **Unit tests** for the scale math. At 260, every derived value equals its v1 constant. At 454, values scale by 454 / 260.
- **Checks without adding watches.** Build a temporary copy of the project, outside the repo, whose manifest lists `fenix7s` and `fr965`. That's how the planning session compiled for other devices. Check the face at 240 and 454 in the simulator, comparing it against the prototype at the same size. Don't commit new products in this ticket.

## Acceptance

- [ ] At 260 the face is pixel-identical to v1: the unit tests pin the values, and a simulator screenshot matches the v1 one.
- [ ] Fonts exist for all eight sizes, and the build uses the right set per device.
- [ ] At 240 and 454 the simulator matches the prototype at the same size.
- [ ] Unit tests pass (`monkeydo … -t`).
