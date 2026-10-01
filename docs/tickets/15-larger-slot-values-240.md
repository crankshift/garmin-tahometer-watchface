# 15: Larger Slot values on 240 px watches, release 0.3.2

Status: partial
Depends on: 14
Spec: [`docs/specs/multi-device.md`](../specs/multi-device.md) "Scaling"

## Goal

On the 240 px MIP watches, the Slot values are drawn at 22 px instead of the 18 px that pure scaling gives, and 0.3.2 goes to the Connect IQ Store carrying both this ticket and ticket 14.

## Background

See ticket 14 for the report: a fenix 6S Pro user asked for larger Slot values. Prod packages up to 0.3.0 gave every watch the 260 px base fonts (fixed in #5), so on the prod listing they saw 20 px values on the 240 px layout. With #5 alone, 0.3.1 would shrink them to 18 px, the opposite of what they asked for. After ticket 14 a clean 20 px value also looks lighter than the fat 20 px they have now, so 22 px is the size that reads as larger to them.

The 240 and 260 px screens have about the same pixel density (fenix 6S Pro 1.2" at 240 px, fenix 7 Pro 1.3" at 260 px), so 22 px at 240 is physically a little larger than the 20 px Slot values on the fenix 7 Pro.

Fit, worked out from the font's advances with ticket 14's 1 px guard, at 22 px:

- Widest values: `88888` steps about 55 px, `12:48` sunrise about 48 px, `100%` about 47 px.
- At 240 px the Left, Center and Right Slot points are 64.6 px apart (70 px × 240 / 260), so two 5-digit values side by side leave about 9 px between them.
- The Left value's outer edge sits about 28 px from the screen's left edge, where the round screen's edge is at about 14 px.

## Scope

- In `tools/gen_bitmap_font.py`, draw the 240 px `slot_value` font at 22 px rather than the scaled 18, through a per-font, per-resolution override with a comment pointing to the spec. Only that one font at that one size changes. The small font, the Gear and the Tachometer numerals keep their scaled sizes.
- Regenerate the fonts.
- Check the fit in the simulator on `fenix6spro`. The agent can't set activity data through the Simulation menu, so use a throwaway copy where `Readouts` returns fixed worst-case text: `88888` in Left and Center, `100%` in Right, `-12°` with its icon in Bottom. Put the source back afterwards. Nothing may overlap, and nothing may be clipped by the screen edge or the Fuel Gauge. If 22 px doesn't fit, use 21 px, and record that under Decisions.
- Peak memory on `fenix6spro`, which has the smallest limit (96 KB): the maintainer opens File > View Memory, and the agent reads it from a screenshot of the simulator window. It must stay under 85%.
- `docs/specs/multi-device.md`, "Scaling": record the exception. The 240 px Slot value font is 22 px, not the scaled 18, because scaling made Slot values hard to read on the small screens.
- Set the version in `manifest.xml` to 0.3.2.
- Export the prod package with `DEVELOPER_KEY=~/.ciq/developer_key.der tools/export_iq.sh prod` (see Comments).
- Maintainer: upload 0.3.2, then reply to the customer once it's live.

## Acceptance

- [x] The 240 px `slot_value` font is 22 px (or 21 px, with the reason recorded), and every other font is at its scaled size.
- [x] A simulator window screenshot on `fenix6spro` with the worst-case values shows no overlap or clipping.
- [ ] Peak memory on `fenix6spro` is recorded here, under 85% of the simulator limit.
- [x] Unit tests pass on `fenix6spro`.
- [x] The spec records the 240 px exception.
- [x] `manifest.xml` says 0.3.2, and `bin/tachometer-prod.iq` builds.

## Decisions

Agreed with the maintainer in a grilling session on 2026-10-01:

- **Only the 240 px set changes size.** The fenix 7 Pro's 260 px Slot values read fine once ticket 14 cleans them up.
- **One font for all four Slots.** The Bottom Slot grows too. It has room, and a second font would cost memory on the 96 KB watches for nothing.
- **0.3.2, one upload with both fixes.** It fixes legibility and adds nothing, so it isn't 0.4.0. Shipping #5 alone would first shrink the customer's text and then grow it again.

## Comments

- 2026-10-01: `~/.garmin/tachometer-watchface/` holds only `developer_key.pem` now. The `.der` that `AGENTS.md` and `tools/export_iq.sh` expect there is gone. `~/.ciq/developer_key.der` is the same key: its public key has the same fingerprint as the `.pem`'s. Sign with that, or the store rejects the update as coming from a different key. Either put a `.der` back at the default path, or update `AGENTS.md`.

## Results

Done on 2026-10-01, except the peak memory figure and the maintainer's steps.

- **Generator.** `tools/gen_bitmap_font.py` has `SIZE_OVERRIDES = {("slot_value", 240): 22}`, applied through `font_size`. Regenerating changes only `resources-round-240x240/fonts/slot_value.fnt` and `.png`. Every other font and size is unchanged.
- **Fit.** Checked on `fenix6spro` with a throwaway `Readouts.get` that returned `88888` in Left and Center, `100%` in Right and `-12°` with the partly cloudy icon in Bottom. Nothing overlaps, the Left and Right values stay well inside the screen edge, and the Bottom value clears the Fuel Gauge. 22 px fits, so there is no fallback to 21 px. The source was put back (`git checkout source/Readouts.mc`).
- **Memory.** Not recorded yet. The simulator's status bar read 38.0 of 91.8 kB (about 41%) on `fenix6spro` with the final build, which is the current figure and not the peak. The peak from File > View Memory still has to be read and written here, and the box above stays open until then.
- **Tests.** 99 of 99 unit tests pass on `fenix6spro`.
- **Spec.** `docs/specs/multi-device.md` "Scaling" records the 240 px exception.
- **Release.** `manifest.xml` says 0.3.2. `DEVELOPER_KEY=~/.ciq/developer_key.der tools/export_iq.sh prod` built all 146 products into `bin/tachometer-prod.iq`.
- **Left for the maintainer.** Read the peak memory, upload 0.3.2 to the Connect IQ Store, and reply to the customer once it's live.
