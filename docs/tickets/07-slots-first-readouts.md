# 07: Slots and first Readouts

Status: done: confirmed working on the real fenix 7 Pro on 2026-09-24, which covers the checks this ticket couldn't do in the simulator. Before that it was partial: implemented, all pure logic unit-tested, build succeeds; not confirmed visually in the simulator this session (see "Verification method")
Depends on: 02
Prototype reference: `drawSlot`, `READOUTS`, `iconSteps`, `iconHeart`, `iconBattery`

## Goal

The four Slots with their layout and settings, plus the Readouts that need no weather data.

## Scope

- **Slots:**

  | Slot | Position | Layout |
  |------|----------|--------|
  | Left | `(CX - 70, CY + 38)` | stacked |
  | Center | `(CX, CY + 38)` | stacked |
  | Right | `(CX + 70, CY + 38)` | stacked |
  | Bottom | `(CX, CY + 84)` | inline |

  - Stacked: the icon (or head text) is centered 11 px above the Slot point, and the value 10 px below it.
  - Inline: the icon, a 5 px gap, then the value, centered as one group.
- **Readouts:** each one gives an icon or a head text, a value string, and optional colors. Missing data shows `--`. No text labels.
  - **Date:** head is the weekday in light grey (`WED`, see the language decision in ticket 02), value is the day of the month.
  - **Steps:** `ActivityMonitor.getInfo().steps`, raw count. The footprint icon turns green once steps reach `stepGoal`.
  - **Heart rate:** the latest bpm, for example from `Activity.getActivityInfo().currentHeartRate` or the newest `SensorHistory` sample. Red heart icon. In low power this refreshes once a minute.
  - **Battery %:** `System.getSystemStats().battery`, rounded, with `%`. Horizontal battery icon filled to the level.
  - **Empty:** nothing.
- **Settings:** four list settings, one per Slot, each offering every Readout in the design (ticket 08 adds the remaining ones). Defaults: Center is date, Left is steps, Right is heart rate, Bottom is weather. Until ticket 08 lands, weather shows `--`.

## Decisions

- **Readout representation.** No closures/first-class functions: a `ReadoutContent` class (`kind`, `head`, `text`, `iconColor`, `textColor`) stands in for the prototype's per-Readout function returning a `{icon|head, text, ...}` record. `Slots.mc` dispatches icon drawing back through `Readouts.drawIcon(dc, kind, x, y, color)` rather than storing a function reference on the record, keeping everything statically typed.
- **Readout kind constants.** `Readouts.DATE`/`STEPS`/`WEATHER`/`HEART_RATE`/`BODY_BATTERY`/`SUN`/`NOTIFICATIONS`/`BATTERY`/`EMPTY` are `Number` constants (0-8) — both the list settings' values and the source of truth for `Readouts.get`'s dispatch. Same string/number reasoning as ticket 03: settings only support `list` on `number` properties.
- **Settings scaffolding ahead of ticket 08.** Per this ticket's own scope note, `settings.xml`'s four Slot lists already offer all 9 Readouts now, not just the 5 implemented here. `Readouts.get` returns the ticket's explicit placeholder (grey cloud, `--`) for Weather, and `null` (nothing drawn, same as Empty) for Body Battery/Sunrise-sunset/Notifications until ticket 08 replaces those branches. `Icons.drawCloud` is added now (for the Weather placeholder) and reused unchanged by ticket 08's real "no weather data" case.
- **Weekday text.** Uses `Time.Gregorian.info(Time.now(), Time.FORMAT_MEDIUM).day_of_week`, which the SDK docs say returns `"Sun"`, `"Mon"`, ... `"Sat"` directly — simpler and less error-prone than a hand-rolled day-index table, and matches ticket 02's English-only decision since the manifest only declares the `eng` language. Uppercased via `Readouts.dateHead` to match the prototype's `WED` styling.
- **Heart rate source.** `Activity.getActivityInfo().currentHeartRate`, the simpler of the two options the ticket names ("for example ... or the newest SensorHistory sample"); null-safe against both a null `Info` and a null `currentHeartRate`.

## Verification method

Same Accessibility-permission constraint as tickets 04-06 for driving simulator scenarios, plus: two consecutive screenshot attempts in this ticket's session mistimed the simulator-window activation and instead captured unrelated foreground windows on the user's screen (flagged to the user in-session, not saved or referenced). Given that, simulator screenshots are dropped for the rest of this session; verification here is build success (`monkeyc`, clean) plus the full unit test suite (`monkeydo -t`, 31/31 passing, including 8 new Readouts tests covering date-head casing, the `--` fallback, the steps goal color threshold, and battery text rounding).

## Acceptance

- [x] The default layout matches the prototype's layout B: steps, date and heart rate in a row, weather below. — `properties.xml` defaults: `LeftSlotReadout=1` (Steps), `CenterSlotReadout=0` (Date), `RightSlotReadout=3` (Heart rate), `BottomSlotReadout=2` (Weather), matching `Slots.LEFT`/`CENTER`/`RIGHT`/`BOTTOM` positions from the ticket's table. Not confirmed visually this session (see "Verification method").
- [ ] Each Readout can be put in each Slot, and nothing overlaps the Gear or the Fuel Gauge. Check the widest values, such as `12345` steps and `100%`. — not confirmed visually. By geometry review: Slot row is at `CY + 38` (value text center at `CY + 48`) and the Fuel Gauge's icons sit at radius `R - 16` around 223°/317° (well below and to the sides); the Bottom Slot is at `CY + 84`, inline layout is width-driven (`x0` computed from measured text width) so it stays centered regardless of value width. Not re-measured for `12345`/`100%` specifically.
- [x] Missing heart rate shows `--`. — `Readouts.heartRateReadout()` passes a possibly-null `currentHeartRate` through `formatOrDash`, unit-tested generically (`testFormatOrDashShowsDashForMissingData`).
- [ ] Changing a Slot setting in the app updates the face. — relies on the same `Application.AppBase.onSettingsChanged → WatchUi.requestUpdate()` mechanism ticket 03 already established for Minute Style; not re-confirmed live this session.
