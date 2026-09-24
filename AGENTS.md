# Tachometer Watch Face

A Garmin Connect IQ watch face in Monkey C for the fenix 7 Pro (`fenix7pro`, 260×260 round MIP display, 64 colors). `README.md` covers building, testing and sideloading. `docs/design.md` is the v1 spec, and `docs/specs/multi-device.md` adds more watches. Both win over `prototype/index.html` when they disagree.

## Working here

- Name things with the `CONTEXT.md` glossary. Each term gets its own source module (`Tachometer.mc`, `Gear.mc`, `RevBar.mc`, ...).
- Unit tests are `(:test)` functions in `<Module>Test.mc`, next to the module they cover. Pure logic gets a unit test; drawing is checked in the simulator.
- Colors come from the 64-color MIP palette listed under "Shared facts" in `docs/tickets/README.md`. The watch face memory limit is 128 KB.
- On the maintainer's machine the developer key is `~/.garmin/tachometer-watchface/developer_key.der`, and `monkeyc` needs `JAVA_HOME=/opt/homebrew/opt/openjdk`.

## Connect IQ gotchas

- A `settingConfig type="list"` only works on a `number` property. List settings store `0`, `1`, `2`, ... and the code compares them with `==`.
- The `filename` in a resource XML resolves relative to that XML file's own directory, not to `resources/`.
- An agent session can't drive the simulator's Simulation menu (setting the time, battery level or low-power mode). Verify those scenarios with a clean build and the unit tests. `screencapture` has grabbed unrelated windows from the user's screen, so ask before taking a screenshot. For the multi-device tickets (10 to 13) the maintainer has allowed screenshots of the simulator window only, taken with `screencapture -l <window id>`. The maintainer opens the memory view and switches low-power mode on when a check needs it.

## Agent skills

### Issue tracker

Tickets are local markdown files in `docs/tickets/`, indexed in `docs/tickets/README.md`. See `docs/agents/issue-tracker.md`.

### Triage labels

The five default triage roles, recorded as a ticket's `Status:` value. See `docs/agents/triage-labels.md`.

### Domain docs

Single-context: `CONTEXT.md` and `docs/adr/` at the repo root. See `docs/agents/domain.md`.
