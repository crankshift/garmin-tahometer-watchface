# 13: AMOLED watches

Status: partial: the real low-power switch on `fr265s` and `fr965` waits for the maintainer
Depends on: 11
Spec: [`docs/specs/multi-device.md`](../specs/multi-device.md), "AMOLED, awake" and "AMOLED, always-on"
Prototype reference: the AMOLED extras panel; `redlineGradient`, `glowStroke`, `drawGlow`, `drawAod`, `drawAodFuelGauge`, `measureAod`

## Goal

The face runs on the 48 in-scope AMOLED watches. When awake it shows the five AMOLED extras, and when the watch sleeps it shows the always-on view, which stays under Garmin's 10% lit-pixel limit.

## Scope

- **Check the prototype first**, at 360, 390, 416, 454 and 466, awake and always-on.
- **AMOLED detection at runtime:** `System.getDeviceSettings().requiresBurnInProtection` is true on AMOLED watches. MIP watches on API 3.x must never call API 4.0+ functions (`Graphics.createColor`, `Dc.setStroke`, `Dc.setFill`), so guard those calls behind the AMOLED flag or `has` checks.
- **Awake extras**, as described in the spec:
  1. Anti-aliasing: it's already on for every screen, so nothing to do.
  2. The Redline gradient, drawn as half-minute arcs.
  3. The Minute Style glow.
  4. The Rev Bar glow. These glows are three alpha strokes each, scaled by `s`.
  5. The Gear glow.
- **New fonts:** `tools/gen_bitmap_font.py` gains two fonts at each AMOLED resolution:
  - `gear_glow`: the Gear digits with a Gaussian blur baked in, at about 45% opacity.
  - `gear_outline`: the Gear digits as an outline only, for the always-on view.

  `Rez.Fonts` ids have to exist on every device, MIP included. So either ship these fonts in every resolution folder and load them only on AMOLED, or put tiny stand-ins in `resources/fonts/`. Pick whichever builds and measures smaller.
- **Always-on view.** On AMOLED, `onEnterSleep` switches `onUpdate` to the always-on view from the spec:
  - the major ticks and numerals;
  - the outline Gear, plus AM/PM;
  - a thin needle;
  - the Slots, with values dimmed;
  - a thin Fuel Gauge.

  AMOLED watches never call `onPartialUpdate`, so the Rev Bar stays off whatever the setting says.
- **Settings label:** the `AlwaysOnRevBarTitle` string becomes "Always-on Rev Bar (MIP only)".
- **Manifest, 48 ids:**
  - **360:** `fr265s`, `venu2s`.
  - **390:** `approachs50`, `approachs7042mm`, `descentg2`, `descentmk343mm`, `epix2pro42mm`, `fr165`, `fr165m`, `fr170`, `fr170m`, `fr57042mm`, `fr70`, `instinct3amoled45mm`, `instinctcrossoveramoled`, `marq2`, `marq2aviator`, `venu3s`, `venu441mm`, `vivoactive5`, `vivoactive6`.
  - **416:** `d2airx10`, `d2mach1`, `epix2`, `epix2pro47mm`, `fenix843mm`, `fenix943mm`, `fenix9pro43mm`, `fenixe`, `fr265`, `instinct3amoled50mm`, `venu2`, `venu2plus`.
  - **454:** `approachs7047mm`, `d2mach2`, `d2mach2pro`, `descentmk351mm`, `epix2pro51mm`, `fenix847mm`, `fenix8pro47mm`, `fenix947mm`, `fenix9pro47mm`, `fr57047mm`, `fr965`, `fr970`, `venu3`, `venu445mm`.
  - **466:** `fenix9pro51mm`.
- **Launcher icon:** AMOLED watches want 54–70 px icons, and ours is 40×40. Check the build warnings and how the scaled icon looks. If it's blurry, add a 70×70 icon for the AMOLED resolutions.
- **Simulator:**
  - `fr265s` (360) and `fr965` (454), awake and always-on. The maintainer switches on low-power mode, since agents can't drive the simulator's menus.
  - Measure the always-on lit pixels from the screenshot: count the non-black pixels inside the screen circle, for example with Pillow, with all four Slots filled. The result must be under 10%.
  - Peak memory on `fr965`, which uses the biggest fonts of the watches checked.
- **Docs:** update the device lists in the README, `AGENTS.md` and `docs/design.md`, and describe the AMOLED look in `docs/design.md`.

## Acceptance

- [x] The prototype at all five AMOLED sizes shows no layout problems.
- [x] The 48 ids are in the manifest, and `monkeyc -e` builds all 91 products.
- [x] All five extras show on `fr265s` and `fr965` when awake, and nothing changes on MIP watches.
- [ ] The always-on view on `fr265s` and `fr965` matches the spec, and its lit-pixel share is recorded here, under 10%. Drawn and measured on a throwaway build that starts asleep (see Results); the real low-power switch is still to check.
- [x] Peak memory on `fr965` is recorded here, under 85% of 128 KB.
- [x] The setting reads "Always-on Rev Bar (MIP only)".
- [x] The README, `AGENTS.md` and `docs/design.md` are updated.

## Results

Started on 2026-09-24.

- **Prototype.** Checked first, at 360, 390, 416, 454 and 466, awake and always-on: nothing clipped or overlapping. The always-on view lights 6.4%, 6.2%, 6.0%, 5.9% and 5.9% of the screen there.
- **Build.** `monkeyc -e` builds all 91 products (146 of 146 part numbers) with no errors. The warnings are the ignored old-firmware part numbers of the fenix 5 Plus watches, and the launcher icon ones (see below).
- **Unit tests.** 93 of 93 pass on `fenix7pro`, `fenix6pro` (API 3.4, so the `has` guards compile), `fr965` and `fr265s`.
- **MIP is unchanged.** Screenshots of the `fenix7pro` simulator window at a fixed time, this build and the one before this ticket, differ only in the memory readout under the window. Code and data grew, though: 15.0 to 18.5 KB on `fenix7pro`, and 20.2 to 25.7 KB on `fenix6pro` (`--build-stats 0`). `fenix6s` peaked at 32.9 kB of 91.8 kB in ticket 12; if its code grew like `fenix6pro`'s it would peak near 38 kB (42%), still far under 85%.
- **Awake extras.** Screenshots of the simulator window on `fr265s` and `fr965`, with the clock forced past minute 50 and to other minutes and Minute Styles: the Redline gradient (unlit, and lit up to the Sweep's minute), the Glow behind the Sweep, Tip, Needle, Rev Bar and Gear, and anti-aliased text. They match the prototype at the same size.
- **Always-on view.** Screenshots of `fr265s` and `fr965` on a throwaway build where `_awake` starts `false`, with all four Slots filled (the simulator's data): it matches the spec. Lit share, from the screenshot, inside the display circle (found from the thin ring the simulator draws around it):

  | Device | Any pixel above 8/255 | Display pixels at least half lit | Prototype |
  |---|---|---|---|
  | `fr265s` (360) | 7.8% | 6.1% | 6.4% |
  | `fr965` (454) | 7.1% | 5.8% | 5.9% |

  With a 12-hour clock showing 10 PM (AM/PM drawn) they are 7.7% and 7.1%, and 6.1% and 5.9% half-lit, so AM/PM doesn't change the picture. The simulator draws the display at 2× with smoothing, so the first column counts the fringe around every edge, and is an upper bound. The simulator also adds a faint grid of value-1 pixels, which the 8/255 cut-off skips. Both columns are under 10%.
- **Launcher icon.** The 40×40 icon scaled up to 54–70 px came out soft and jagged, so the AMOLED resolutions use a 70×70 one (`tools/gen_launcher_icon.py`, `resources/drawables/launcher_icon_70.png`, chosen by `resources-round-*/drawables/drawables.xml`). Most AMOLED watches want 54 to 65 px, so the build still warns that it scales the icon, now down.
- **Peak memory on `fr965`.** The "Peak Memory" line of the simulator's Active Memory window (File > View Memory), read from a screenshot of that window with the awake face running: **30.0 kB** of the 123.8 kB limit, 24%, far under 85%. The window lists 15,163 bytes of code and 3,367 bytes of data. The fonts don't count: on API 4.0+ they load into the graphics pool, which is separate from the app's memory. On `fenix7pro` the footer went from 23.6 kB before this ticket to 27.5 kB.

## Decisions

- **Stand-in fonts, not real ones in every folder.** `Rez.Fonts.GearGlowFont` and `GearOutlineFont` need to exist on every watch, so `resources/fonts/` holds a 2×2 px glyph for each, and the 240 and 280 folders inherit them. On `fenix7pro` that builds to 129,884 bytes, against 132,172 with real fonts in the 260 folder, and on `fenix6pro` to 135,644 against 141,628. (A one-pixel glyph fails to compile: "Width (0) and height (1) cannot be <= 0".)
- **AMOLED fonts are anti-aliased.** A bitmap font is 1-bit unless its `<font>` has `antialias="true"`, so the fonts the spec assumed were anti-aliased were not: the Gear glow came out as a solid white blob and small text like the Date's head was jagged. The AMOLED font sets now have the attribute, and their sheets are grayscale, as in the SDK sample. The MIP sets are untouched.
- **Four coverage levels.** An anti-aliased Connect IQ font has only four levels (none, ⅓, ⅔, full), cutting at gray 56, 136 and 216 (measured with a ramp font in the simulator). `tools/gen_bitmap_font.py` writes the AMOLED sets with the levels already picked.
- **The Gear glow is three bands, in 22% white.** A 45% blur baked into a font falls to level 1 or 0 almost everywhere outside the digits, so nothing shows. Instead the blur is cut into three brightness bands, and the face draws it in 22% white (`Constants.COLOR_GEAR_GLOW`), which is what a 45% blurred digit shows at the edge of its strokes. The spec says so now.
- **The Gear glow is drawn one digit at a time.** Connect IQ draws a glyph only inside its advance, which cut the halo off at the ends of the string. The glow font's advances are wider than the Gear's by the halo's reach on both sides, and `Gear.drawGlow` places each digit's glow from the Gear font's advances.
- **The outline Gear is a ring just inside the digit's edge**, 2 px wide at 260 px. It began as a 1.3 px ring outside the digit, cut to the glyph's advance (at most 1 px on `1`, `4` and `7`), but on the Venu 3's low-power panel that was too thin to read, and at 2 px the cut took 2 to 3 px off the sides of `7`, `4` and others. Inside the edge the ring can't reach past the advance, so nothing is cut. The 2 px ring lights about 0.7 points more of the screen than the old one (estimated from the glyph pixels, not measured in the simulator), so the lit shares recorded below are now about that much higher.
- **`setColor` after `setStroke` wins, in the simulator.** The Glow sets a translucent stroke, and the face is drawn afterwards with plain `setColor` calls. The SDK says `setStroke` "takes precedence over `setColor()`", so this was tested: on `fr965`, a line drawn after a translucent `setStroke` and then a `setColor` comes out in the `setColor` color, and a `setStroke` after a `setColor` wins. The Glow therefore doesn't reset the stroke. Not confirmed on a real watch, where a tinted, translucent face (ticks, arcs, lines) would mean the opposite.
- **Sleeping on MIP is unchanged.** `RevBar.isVisible` keeps the Rev Bar off on AMOLED whatever the setting says, and `AlwaysOn.isActive` is true only on AMOLED while asleep.
- **AM/PM used to overlap the Date in 12-hour mode, and is fixed.** `Gear.draw` placed AM/PM from `dc.getFontHeight(gearFont)`, which is the font's line height (107 px on `fenix7pro`), not the digits' cap height that the prototype uses, so on every watch it landed on the Center Slot's head text (the jagged "THU" in the simulator screenshots above was AM/PM printed over it: the simulator's clock was set to 12-hour). It predates this ticket, and the always-on view would have inherited it. AM/PM now sits at a fixed offset from the Gear's center, `Gear.Layout.ampmOffset`, 46 px at 260 px, which is halfway between the bottom of the digits and the Center Slot's head. Checked on `fenix7pro`, `fenix7s`, `fr965` awake and `fr965` always-on, with the clock forced to 10 PM. The 24-hour face on `fenix7pro` is still pixel-identical to the one before this ticket, and only the 12-hour AM/PM position on MIP watches changes.
