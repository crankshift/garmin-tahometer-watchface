# Tachometer Watch Face

A Garmin Connect IQ watch face in Monkey C for the fenix 7 Pro (`fenix7pro`, 260×260 round MIP display, 64 colors) and the other round watches listed in `manifest.xml`: MIP watches with 240, 260 and 280 px screens, and AMOLED watches with 360 to 466 px screens. `README.md` covers building, testing and sideloading. `docs/design.md` is the v1 spec, and `docs/specs/multi-device.md` adds more watches. Both win over `prototype/index.html` when they disagree.

## Working here

- Name things with the `CONTEXT.md` glossary. Each term gets its own source module (`Tachometer.mc`, `Gear.mc`, `RevBar.mc`, ...).
- Unit tests are `(:test)` functions in `<Module>Test.mc`, next to the module they cover. Pure logic gets a unit test; drawing is checked in the simulator.
- Every fixed pixel value is written for the 260 px screen and scaled by the screen radius (`docs/specs/multi-device.md`, "Scaling"). Put it in the module's `Layout` class, which `onLayout` rebuilds through the module's `fit`, or multiply by `Screen.scale` where a module has no layout (`Icons.mc`). Don't add a bare pixel constant.
- Colors come from the 64-color MIP palette listed under "Shared facts" in `docs/tickets/README.md`. The AMOLED extras (the Redline gradient, the Glow, the always-on view's dark red) are the exception: they use other colors, and only run when `Screen.amoled` is set. The watch face memory limit is 128 KB on the fenix 7 Pro and differs per watch, from 96 KB to 512 KB; the table in `docs/specs/multi-device.md` has each group.
- On the maintainer's machine the developer key is `~/.garmin/tachometer-watchface/developer_key.der`, and `monkeyc` needs `JAVA_HOME=/opt/homebrew/opt/openjdk`.

## Connect IQ gotchas

- AMOLED-only drawing (`Graphics.createColor`, `Dc.setStroke`, the Glow) stays behind `Screen.amoled` and a `has` check, so the API 3.x MIP watches still compile and run.
- A `settingConfig type="list"` only works on a `number` property. List settings store `0`, `1`, `2`, ... and the code compares them with `==`.
- The `filename` in a resource XML resolves relative to that XML file's own directory, not to `resources/`.
- Bitmap fonts are 1-bit unless the `<font>` has `antialias="true"`. An anti-aliased font has four coverage levels (none, ⅓, ⅔, full), read from a grayscale sheet with cut-offs at gray 56, 136 and 216, so `tools/gen_bitmap_font.py` writes the AMOLED sets with those levels already picked. Connect IQ draws a glyph only inside its advance, so nothing may hang over to the side.
- A module-level `const` array read while another module-level `var` is being built fails at run time with `Circular Dependency Error`. Use scalar constants there.
- An agent session can't drive the simulator's Simulation menu (setting the time, battery level or low-power mode). Verify those scenarios with a clean build and the unit tests. `screencapture` has grabbed unrelated windows from the user's screen, so ask before taking a screenshot. For the multi-device tickets (10 to 13) the maintainer has allowed screenshots of the simulator window only, taken with `screencapture -l <window id>`. The maintainer opens the memory view and switches low-power mode on when a check needs it. To look at the always-on view without the menu, build a throwaway copy where `TachometerWatchFaceView._awake` starts as `false`, and put the source back afterwards.

## Agent skills

### Issue tracker

Tickets are local markdown files in `docs/tickets/`, indexed in `docs/tickets/README.md`. See `docs/agents/issue-tracker.md`.

### Triage labels

The five default triage roles, recorded as a ticket's `Status:` value. See `docs/agents/triage-labels.md`.

### Domain docs

Single-context: `CONTEXT.md` and `docs/adr/` at the repo root. See `docs/agents/domain.md`.
