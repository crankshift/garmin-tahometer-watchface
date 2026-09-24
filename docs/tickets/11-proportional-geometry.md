# 11: Proportional geometry and per-resolution fonts

Status: done
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

- [x] At 260 the face is pixel-identical to v1: the unit tests pin the values, and a simulator screenshot matches the v1 one.
- [x] Fonts exist for all eight sizes, and the build uses the right set per device.
- [x] At 240 and 454 the simulator matches the prototype at the same size.
- [x] Unit tests pass (`monkeydo … -t`).

## Decisions

- **`Screen` plus a `Layout` per module.** `Screen.mc` holds the screen (`cx`, `cy`, `radius`, `scale`), `fit(width)` and the pure scale math (`scaleFor`, `penWidth`, `strokeWidth`). `Tachometer`, `RevBar`, `Gear`, `FuelGauge` and `Slots` each have a `Layout` class that turns the radius into their scaled values, and a module-level `layout` that `fit(radius)` rebuilds. `onLayout` calls `Screen.fit` and the five `fit`s once, so `onUpdate` and `onPartialUpdate` only read fields. Everything starts as the 260 px screen, so code that runs before `onLayout`, and the existing tests, see v1. `Constants` lost `CX`, `CY` and `R`.
- **`Icons` scales at draw time.** About 60 literals, so a `Layout` there would be a field per literal. Each function multiplies by `Screen.scale`, and the sun's `radius` argument stays the 260 px number.
- **Pen widths.** Bands, ticks, the Tip and the Rev Bar are whole pixels in v1, so they use `Screen.penWidth` (rounded, at least 1 px). Icon strokes are 1.5 px in v1, and rounding that to 2 could change the 260 px face, so they use `Screen.strokeWidth` (not rounded, at least 1 px) and the watch treats them as it always did.
- **Font sizes** are `floor(v1 size × px / 260 + 0.5)`, which rounds halves up. Only the small font at 390 px lands on a half (15 × 390 / 260 = 22.5, so 23 where Python's `round` gives 22). The prototype doesn't round font sizes, since it scales the whole canvas:

  | Screen | gear | tachometer numeral | slot value | small |
  |---|---|---|---|---|
  | 240 | 82 | 22 | 18 | 14 |
  | 260 | 89 | 24 | 20 | 15 |
  | 280 | 96 | 26 | 22 | 16 |
  | 360 | 123 | 33 | 28 | 21 |
  | 390 | 134 | 36 | 30 | 23 |
  | 416 | 142 | 38 | 32 | 24 |
  | 454 | 155 | 42 | 35 | 26 |
  | 466 | 160 | 43 | 36 | 27 |

- **No `resources-round-260x260`.** The 260 set stays in `resources/fonts/`, where every watch without a better match finds it. The script regenerates it byte for byte, so `git diff resources` is empty. `fonts.xml` is now written by the script too.

## Results

Done on 2026-09-24.

- **Unit tests.** 65 of 65 pass on `fenix7pro` and `fenix6pro` (API 3.4), and on `fenix7s` (240) and `fr965` (454) from the throwaway project. 22 are new: the scale math, each `Layout` at 260 (equal to the v1 constants) and at 454 (scaled by 454 / 260), and the Rev Bar clip box growing with the screen.
- **Build.** `monkeyc -e` still builds every product in the manifest.
- **Fonts per device.** A throwaway project outside the repo listed `fenix7s`, `fenix7pro`, `fenix7x`, `fr265s`, `approachs50`, `epix2pro47mm`, `fr965` and `fenix9pro51mm`, one per size, and all eight built. The build picks the qualified folder: `fr965` grows by 1,120 bytes with `resources-round-454x454` present, and `fenix7s` shrinks to 121,836 bytes with `resources-round-240x240`, against 121,948 (the 260 size) without it.
- **260 px is pixel-identical.** Two screenshots of the simulator window on `fenix7pro`, the v1 build and this one, taken in the same clock minute. The only differing pixels are the Rev Bar segments for the 8 seconds between the two shots, and the simulator's memory readout under the window. A throwaway gallery app that draws every icon (all seven weather icons included) at 260 px matches v1 too, apart from that readout.
- **240 and 454.** `fenix7s` and `fr965` in the simulator show the same layout as the prototype's Screen picker at 240 and 454: Tachometer, Gear, Slots, Fuel Gauge and Tip all in proportion, nothing clipped. The digits differ slightly because the prototype's font isn't Barlow, as at 260. The prototype's 454 view also shows the AMOLED glows, which are ticket 13.
