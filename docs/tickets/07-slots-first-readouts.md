# 07: Slots and first Readouts

Status: open
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

## Acceptance

- [ ] The default layout matches the prototype's layout B: steps, date and heart rate in a row, weather below.
- [ ] Each Readout can be put in each Slot, and nothing overlaps the Gear or the Fuel Gauge. Check the widest values, such as `12345` steps and `100%`.
- [ ] Missing heart rate shows `--`.
- [ ] Changing a Slot setting in the app updates the face.
