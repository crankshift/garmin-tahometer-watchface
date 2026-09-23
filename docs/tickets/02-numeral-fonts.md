# 02: Numeral bitmap fonts

Status: open
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

## Acceptance

- [ ] All four fonts load in the simulator and render their glyphs.
- [ ] The two-digit Gear at full size fits inside the Rev Bar ring (radius `R - 50`), as in the prototype.
- [ ] The memory cost of the fonts is noted in this ticket.
- [ ] The font license file is committed next to the font source.
