# 02: Numeral bitmap fonts

Status: done — confirmed loading and rendering in the simulator during the 04-08 session (see "Acceptance"). The anti-aliased-vs-1-bit comparison was still not redone on-device; anti-aliased remains the default per the original decision below.
Depends on: 01

## Goal

The condensed DIN-style numerals from the prototype, on the watch as custom bitmap fonts.

## Scope

- Pick an open-license, DIN-style condensed bold font. The prototype used Apple's DIN Condensed Bold, which cannot be redistributed, so don't ship that. Candidates: D-DIN Condensed Bold or Barlow Condensed Bold (both SIL Open Font License).
- Convert it to BMFont format (`.fnt` plus `.png`) with a bitmap font generator, and add it as a font resource.
- Four sizes, each limited to the glyphs it needs so memory stays small:

  | Use | Size in the prototype | Glyphs |
  |-----|-----------------------|--------|
  | Gear | about 64 px cap height (89 px DIN) | `0`–`9` |
  | Tachometer numerals | 24 px DIN | `0`–`6` |
  | Slot values | 20 px DIN | digits, `-`, `%`, `°`, `:` |
  | Small text (weekday, AM/PM) | 13 to 15 px DIN | the letters actually shown |

- Check how anti-aliased glyph edges look on the 64-color MIP screen compared with 1-bit glyphs, and pick the one that reads better.

## Decisions to make here

- **Weekday language.** The Center Slot's weekday (`WED`) can be English-only, or localized from the watch language, for example `ŚR` in Polish. Localized text means the small font must include those glyphs. Suggested: decide before generating the small font.

## Decisions

- **Font choice.** Barlow Condensed Bold (SIL OFL), from `google/fonts` (`ofl/barlowcondensed/BarlowCondensed-Bold.ttf`, commit reachable at generation time). D-DIN Condensed Bold was the other candidate; Barlow was picked because it's readily available from a canonical, high-trust source (the Google Fonts repo) with an unambiguous OFL license file next to it, and its glyph shapes are close to the prototype's Apple DIN Condensed Bold reference. Source font and `OFL.txt` are committed at `assets/fonts/`.
- **Anti-aliased vs. 1-bit glyphs.** Went with anti-aliased (8-bit alpha-channel coverage, matching `dc.setAntiAlias(true)` already used by ticket 03's drawing code). The ticket asks to compare the two on-device; that comparison needs the simulator, which needs the SDK (blocked, see ticket 01). Anti-aliased is the simplest option that fits `docs/design.md` (nothing in the design mandates 1-bit glyphs), so it's the default until someone can actually look at both on a `fenix7pro` profile.
- **Bitmap font generator.** No BMFont generator (Hiero, bmGlyph, etc.) is installed and none could be installed non-interactively, so `tools/gen_bitmap_font.py` (Python + Pillow, already available) renders the glyph subsets and writes AngelCode BMFont text-format `.fnt` + `.png` pairs directly into `resources/fonts/`. It tight-crops each glyph and derives `xoffset`/`yoffset`/`xadvance` from Pillow's font metrics, so re-running it against the same source TTF reproduces the same output. `chnl=15` (all channels via the alpha channel) is used for AA glyph coverage, the common approach in Connect IQ custom-font tutorials.
- **Font sizes.** Used the pixel sizes from the ticket's table directly as the rendered (bitmap) size, i.e. Gear at 89px and Tachometer numerals at 24px — the same numbers the prototype passes to its CSS font-size, so the two should read the same. Slot Value at 20px matches the prototype's `F_VALUE`.
- **Small font size and glyphs.** The ticket's small-text range (13-15px) covers two different prototype uses at two different CSS sizes: the weekday header (15px, `F_HEAD`) and Gear's AM/PM (13px, `F_SMALL`). Bitmap fonts don't scale at draw time the way CSS fonts do, so one font asset can't serve both sizes. Picked a single 15px `SmallFont` (the weekday size, since it's the more prominent use) for both; AM/PM will render slightly larger than in the prototype once ticket 04 wires it up. This is a minor, deliberate deviation from the prototype's geometry, not a design change — `docs/design.md` doesn't specify a small-text pixel size.
- **Weekday language.** English-only uppercase (per the working rules), so the small font's glyph set is exactly the union of letters used by `MON TUE WED THU FRI SAT SUN AM PM`: `A D E F H I M N O P R S T U W` (computed in `tools/gen_bitmap_font.py`, not hand-typed, to avoid missing a letter).
- **Font resource ids.** `GearFont`, `TachometerNumeralFont`, `SlotValueFont`, `SmallFont` (declared in `resources/fonts/fonts.xml`), matching the `.fnt`/`.png` base names `gear`, `tachometer_numeral`, `slot_value`, `small`.

## Memory cost

Generated `.png` sizes (from `tools/gen_bitmap_font.py`'s output), as a proxy for on-device font memory since the SDK isn't installed to report the real compiled size:

| Font | Glyphs | Sheet | PNG bytes |
|------|--------|-------|-----------|
| `gear.fnt` | 10 (`0`-`9`) | 369x69 | 6287 |
| `tachometer_numeral.fnt` | 7 (`0`-`6`) | 87x21 | 1144 |
| `slot_value.fnt` | 14 (digits, `-`, `%`, `°`, `:`) | 149x19 | 1777 |
| `small.fnt` | 15 (`A D E F H I M N O P R S T U W`) | 138x15 | 1222 |

Total ~10.4 KB of PNG source. The device's actual compiled font resource size (after monkeyc packs it for the watch's frame buffer format) is unverified — needs the SDK.

## Acceptance

- [x] All four fonts load in the simulator and render their glyphs. — `TachometerNumeralFont` confirmed rendering (0-6 numerals) in the ticket 01-03 baseline screenshot; `GearFont`, `SlotValueFont` and `SmallFont` confirmed rendering once wired up in tickets 04 and 07 of this session (see those tickets' Acceptance sections and screenshots). The resource loader also required a fix: `resources/fonts/fonts.xml`'s `filename` attributes had a redundant `fonts/` prefix that made the SDK unable to resolve them (see ticket 01's "Resolved" section).
- [x] The two-digit Gear at full size fits inside the Rev Bar ring (radius `R - 50`), as in the prototype. — see ticket 04's Acceptance and screenshot.
- [x] The memory cost of the fonts is noted in this ticket. — see "Memory cost" above (PNG-size proxy; real device cost still needs the SDK).
- [x] The font license file is committed next to the font source. — `assets/fonts/OFL.txt` next to `assets/fonts/BarlowCondensed-Bold.ttf`.
