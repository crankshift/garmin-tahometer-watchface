# 13: AMOLED watches

Status: open
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

- [ ] The prototype at all five AMOLED sizes shows no layout problems.
- [ ] The 48 ids are in the manifest, and `monkeyc -e` builds all 91 products.
- [ ] All five extras show on `fr265s` and `fr965` when awake, and nothing changes on MIP watches.
- [ ] The always-on view on `fr265s` and `fr965` matches the spec, and its lit-pixel share is recorded here, under 10%.
- [ ] Peak memory on `fr965` is recorded here, under 85% of 128 KB.
- [ ] The setting reads "Always-on Rev Bar (MIP only)".
- [ ] The README, `AGENTS.md` and `docs/design.md` are updated.
