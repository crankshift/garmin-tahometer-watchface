# 14: Clean 1-bit fonts on MIP watches

Status: done
Depends on: none
Blocks: 15
Spec: [`docs/design.md`](../design.md) "Look", [`docs/specs/multi-device.md`](../specs/multi-device.md) "Scaling"

## Goal

On every MIP watch, the bitmap fonts draw at their true outline, and no two glyphs touch. Today they draw about a pixel too fat on each side, so digits run together.

## Background

A Connect IQ Store user on a fenix 6S Pro (240 px, firmware 27.00, prod listing) reported that the values in the Left, Center and Right Slots are too bold, run together and are hard to read, and asked for a slightly larger font. Ticket 15 handles the size. This ticket fixes the cause, which affects every MIP watch, the fenix 7 Pro included.

`tools/gen_bitmap_font.py` writes the MIP sheets with Pillow's anti-aliased alpha, and the resource compiler rounds that to 1 bit. It lights faint edge pixels too, so every glyph grows by about a pixel on each side. Small counters (`6`, `8`, `9`) close up, and glyphs whose ink reaches their advance run into their neighbours.

Found on 2026-10-01 in the simulator on `fenix6spro`:

- With the 240 set (18 px Slot values, what 0.3.1 ships), the `1` and `3` of a `13°` weather value merge into one shape, and the missing-data `--` draws as one long bar. With the 260 base set (20 px, what prod packages up to 0.3.0 put on every watch), `--` is one bar and `13` touches.
- Measured on the sheets, `13` only touches when pixels below alpha 64 are lit. At a cut of 128 both pairs have 2 px between them. At 240 the Slot value `8` has 91 pixels with any alpha, and 52 at alpha 128 or more.
- A throwaway build with the 240 fonts cut at alpha 128 drew `13°` and the `THU` weekday head cleanly. At 20 and 22 px `--` showed two dashes. At 18 px it was still one bar, because the `-` ink fills its whole advance.
- Even cut at 128, some pairs touch at every MIP size: `71`, `74`, `77` and `°1` in the Slot value font, and `EA`, `FA`, `SA` (240) or `AA`, `FA`, `IA`, `WA` (260) in the small font. At 240 the `7` and the `°` reach 1 px past their advance, so Connect IQ cuts them off.

To reproduce the "before" state for prod 0.3.0 and earlier, copy `manifest.xml` into a folder under `bin/` and build it with a jungle there whose source and resource paths point back at the repo. The compiler then misses the `resources-round-*` folders, as the old prod build did.

## Scope

- In `tools/gen_bitmap_font.py`, for the non-anti-aliased sets (240, 260 and 280 px) and every plain font (Gear, Tachometer numerals, Slot value, small, Cyrillic letters included):
  - Cut each glyph's alpha at 128 to fully on or fully off, and crop to that ink, so the compiler gets a clean 1-bit sheet.
  - Make each glyph's advance at least its ink's right edge plus 1 px (`xadvance >= xoffset + width + 1`). Neighbours then always have a clear pixel between them, and nothing reaches past the advance.
- Leave the AMOLED sets (360 to 466 px) and the 2 px stand-ins in `resources/fonts/` alone. After regenerating, `git diff` shows no change under `resources-round-360x360` to `resources-round-466x466`, and the stand-ins are unchanged.
- Regenerate the fonts.
- Docs:
  - `AGENTS.md`, "Connect IQ gotchas": the resource compiler lights faint alpha when it rounds a 1-bit font, so the generator writes the MIP sheets already cut at 128, with a 1 px gap guard.
  - `docs/design.md`, the font line under "Look": the MIP sets are cut at the outline, with at least 1 px between glyphs.
  - `docs/specs/multi-device.md`, "Scaling": drop "must stay pixel-identical to v1". The 260 px geometry is still v1's, but its fonts were re-cut here.
  - The generator's docstring, which still says the 260 px face stays pixel-identical to v1.

## Acceptance

- [x] The MIP sheets have only alpha 0 and 255, and every MIP glyph has `xadvance >= xoffset + width + 1`.
- [x] Regenerating leaves the AMOLED sets and the stand-ins byte-identical.
- [x] Simulator window screenshots, before and after, on `fenix6spro` (240), `fenix7pro` (260) and `fenix7x` (280): `13°` and `--` draw with clear gaps, the `6`/`8`/`9` counters are open, and the weekday head and AM/PM read cleanly.
- [x] Unit tests pass on those three watches, and `monkeyc -e` builds every product.
- [x] The docs listed above are updated.

## Decisions

- **All MIP sizes, not just 240.** Agreed with the maintainer in a grilling session on 2026-10-01. The fenix 7 Pro has the same fault, so the 260 face changes slightly (thinner, cleaner glyphs), and "pixel-identical to v1" no longer holds for the fonts. That rule only guarded the multi-device migration.
- **AMOLED stays as it is.** Its fonts are anti-aliased, with four levels that the generator already picks, so the compiler doesn't round them.
- **Fix the cause, not only the size.** The customer asked for a larger font. A larger font alone would still be fat and would still touch.

## Results

Done on 2026-10-01.

- **Generator.** `tools/gen_bitmap_font.py` cuts every non-anti-aliased glyph's alpha at 128 (`ONE_BIT_CUT`) before it crops, and sets `xadvance = max(xadvance, xoffset + width + 1)` for them, Cyrillic letters included. The anti-aliased path is untouched. The docstring now says the MIP fonts were re-cut and are not pixel-identical to v1.
- **Fonts.** Regenerating changes 24 files: the four plain fonts (`gear`, `tachometer_numeral`, `slot_value`, `small`), `.fnt` and `.png`, in each of `resources/fonts` (260), `resources-round-240x240/fonts` and `resources-round-280x280/fonts`. A checksum of every font file before and after shows the five AMOLED sets (360 to 466 px) and the `gear_glow` and `gear_outline` stand-ins byte-identical. Every MIP sheet has only alpha 0 and 255, and every MIP glyph meets `xadvance >= xoffset + width + 1`.
- **Simulator, before and after.** Window screenshots on `fenix6spro` (240), `fenix7pro` (260) and `fenix7x` (280), the "before" built from this branch before the change (its code is the same as `main`'s):
  - `13°` was one merged shape on all three before and draws as two clear digits and a degree sign after.
  - `--` was one bar before and shows two dashes after.
  - The `6` of the Tachometer has an open counter. The Gear showed `7` during the check, so the `8` and `9` counters were checked on the sheets only (see the pixel counts under Background), not on screen.
  - `THU` and `PM` read cleanly, with a gap between the letters.
- **Tests.** 99 of 99 unit tests pass on `fenix6spro`, `fenix7pro` and `fenix7x`. `monkeyc -e` builds all 146 products and ends with `BUILD SUCCESSFUL`.
- **Docs.** `AGENTS.md` ("Connect IQ gotchas"), `docs/design.md` ("Look") and `docs/specs/multi-device.md` ("Scaling") are updated as the scope says.
