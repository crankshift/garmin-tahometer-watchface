# Spec: Multi-device support

Agreed on 2026-09-24 in a grilling session, after the v1 face was confirmed working on a real fenix 7 Pro. The vocabulary lives in [`CONTEXT.md`](../../CONTEXT.md), and the v1 design in [`docs/design.md`](../design.md) still holds wherever this spec doesn't say otherwise. The HTML prototype ([`prototype/index.html`](../../prototype/index.html)) renders everything below: its Screen picker lists every supported size, and its AMOLED panel shows the extras and the always-on view.

The work is split into tickets 10 to 13 (see [`docs/tickets/README.md`](../tickets/README.md)).

## Goal

Run the face on every round Garmin watch where its layout makes sense. This is groundwork for a public Connect IQ Store release; the release itself is a separate decision.

## Devices

The rule: a round screen, Connect IQ API 3.3 or newer (the project's `minSdkVersion`, which Body Battery and sunrise/sunset need), and either

- a MIP screen of 240, 260 or 280 px, or
- an AMOLED screen of 360 to 466 px on API 5.0 or newer.

That gives 91 device ids, taken from the device profiles in SDK 9.2.0 (`compiler.json` in each device folder):

| Screen | Ids | Watch face memory | Ticket |
|---|---|---|---|
| MIP 260 | 13 (12 new) | 112 KB on fenix 6 / 6 Pro, 512 KB on vívoactive 4 and the Legacy editions, 128 KB on the rest | 10 |
| MIP 240 | 21 | 128 KB on fenix 7S / 7S Pro, 96 KB on the rest | 12 |
| MIP 280 | 9 | 112 KB on Enduro, 128 KB on the rest | 12 |
| AMOLED 360–466 | 48 | 128 KB | 13 |

The exact ids are listed in each ticket.

Left out:

- Screens of 208 and 218 px (FR 55, FR 255S, vívoactive 4S, and others). Scaling the face down that far makes the Slot text too small.
- Rectangular screens, Instinct-style screens with a subwindow, and Lily.
- The first-generation Venu (API 3.3 AMOLED). It has no alpha blending, which the AMOLED glows need.
- Anything below API 3.3, such as fenix 5 / 5S / 5X, FR 645 / 935, vívoactive 3 and Approach S62.

Instinct 3 AMOLED and Instinct Crossover AMOLED are in. The SDK lists them as plain round 390 and 416 px screens.

The fenix 5 Plus, 5S Plus and 5X Plus are in, but only on firmware with Connect IQ 3.3 or newer. Their profiles also list an older firmware (3.2.8), and the package tool skips that part number with a warning. The id list doesn't change.

**Memory rule.** If a device group's peak memory in the simulator goes over 85% of its watch face limit, drop that group, or make its fonts smaller. On API 3.x watches the code and data compile to about 17 KB, against about 12 KB on API 5 (`monkeyc --build-stats 0`), because API 3.x uses older bytecode.

## Scaling

- Everything scales in proportion to the screen. The scale factor is `s = R / 130`, where `R` is half the screen width. Every radius offset, position offset, icon size and pen width that is written for 260 px today gets multiplied by `s`. At 260 px (`s = 1`) the face must stay pixel-identical to v1.
- `tools/gen_bitmap_font.py` generates the bitmap fonts once per resolution, at the v1 pixel sizes multiplied by `s`, into `resources-round-WxH/fonts/`. `resources/fonts/` stays the 260 set.
- The face looks the same on every screen, just bigger or smaller.

## MIP watches

MIP watches look and behave exactly as `docs/design.md` describes, at every size.

## AMOLED, awake

The awake face on AMOLED is the same face, in the same colors, plus five extras. There is no setting to turn them off.

1. **Anti-aliasing.** The face already calls `dc.setAntiAlias(true)` on every screen. It only makes a visible difference on AMOLED. Bitmap fonts are 1-bit unless their `<font>` says `antialias="true"`, so the AMOLED font sets do (found in ticket 13). Anti-aliased fonts have four coverage levels.
2. **Redline gradient.** The unlit Redline band runs from `0x220000` at minute 50 to `0x770000` at minute 60. Past minute 50, the lit Sweep runs from `0xAA0000` to `0xFF3300`. Both are drawn as half-minute arcs, because the watch has no gradient fill. The color at a given minute never changes, so a Sweep that stops at minute 53 ends in the minute-53 color.
3. **Minute Style glow.** An amber glow (red past minute 50) around the Sweep, the Tip and the Needle.
4. **Rev Bar glow.** A white glow (red past second 50) around the lit Rev Bar.
5. **Gear glow.** A soft white glow behind the Gear.

The watch can't blur shapes, so each arc or needle glow is three wider strokes at low alpha, drawn widest first. At the 260 scale, each stroke extends past the shape on both sides by 5, 3.5 and 2 px, at alpha 0.10, 0.16 and 0.26. The strokes use `Graphics.createColor` with alpha (API 4.0+). The Gear glow is a pre-blurred bitmap font, drawn under the Gear. Since a font has only four coverage levels, the blur is baked as three brightness bands and drawn in 22% white, which is what a 45% blurred digit shows at the edge of its strokes (found in ticket 13).

## AMOLED, always-on

When the watch sleeps, AMOLED watches switch to an always-on view that is redrawn once a minute. It shows:

- The major ticks 0 to 6 and their numerals, in light grey, or dark red `0xAA0000` for the Redline ones. The ticks are 2 px wide.
- The Gear as an outline, drawn with its own outline bitmap font, in light grey. In 12-hour mode it has AM/PM, like the awake face.
- The minute as a thin floating needle, 2 px wide, amber (red past minute 50), whatever the Minute Style.
- All four Slots. Values that are white when awake turn light grey; icons keep their usual colors.
- A thin Fuel Gauge showing only the lit segments, 3 px wide, in light grey. The Low-Fuel Lamp shows only at 20% battery or below.

It leaves out:

- **The Rev Bar.** AMOLED watch faces get no partial updates, so the Always-on Rev Bar setting has no effect on AMOLED.
- **A pixel shift against burn-in.** Garmin's per-pixel burn-in rule only applied to the first-generation Venu, which is out of scope.

If the always-on view lights more than 10% of the screen, the watch blanks it. Since Connect IQ 7, watches reportedly measure overall brightness instead of pixel count, which is less strict. So the rule is: under 10% of pixels lit, counting every non-black pixel as lit, with all four Slots filled.

## Settings

The settings don't change. A setting that only works on one type of display says so in its title: "Always-on Rev Bar" becomes "Always-on Rev Bar (MIP only)". Any future settings like that get "(MIP only)" or "(AMOLED only)".

## Verification

- Every new size gets checked in the prototype first, using the Screen picker, before any simulator run.
- The simulator only runs on representative watches:

  | Screen | Look check | Memory check |
  |---|---|---|
  | MIP 240 | fenix 7S | fenix 6S (96 KB) |
  | MIP 260 | fenix 6 Pro | fenix 6 Pro (112 KB), fenix 7 Pro |
  | MIP 280 | fenix 7X | Enduro (112 KB) |
  | AMOLED | FR 265S (360), FR 965 (454), both awake and always-on | FR 965 |

- The agent runs the simulator and takes screenshots of the simulator window only (`screencapture -l <window id>`). Agents can't drive the simulator's menus, so the maintainer opens the memory view (File > View Memory) and switches low-power mode on when a check needs it.
- On a real watch, the maintainer only checks that the face runs and works. There are no battery or sunlight measurements.

## Release

The version goes to 1.1.0 once tickets 10 to 13 are merged. That build gets uploaded as a new Connect IQ Store beta. Installing from the Store is what makes the phone-app settings appear; sideloaded builds never get them.

## Sources

- [DC Rainmaker: Garmin's Connect IQ platform updates (2021)](https://www.dcrainmaker.com/2021/10/garmins-connect-platform.html): the Venu 1 always-on rules, and the Venu 2 skipping the per-pixel burn-in detector while under 10% lit.
- [Garmin forums: always-on display rules on newer AMOLED watches](https://forums.garmin.com/developer/connect-iq/f/discussion/322419/always-on-display-sleep-mode-behaviour-and-rules-on-newer-amoled-watches): going over 10% blanks the always-on face.
- [the5krunner: CIQ 7 deep dive](https://the5krunner.com/2023/12/20/garmin-to-introduce-ble-bonding-and-more-in-ciq-7/): Connect IQ 7's switch from a pixel-count check to an overall brightness check.
