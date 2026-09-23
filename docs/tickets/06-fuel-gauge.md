# 06: Fuel Gauge

Status: partial: implemented, all logic unit-tested against the ticket's exact scenarios, and rendering confirmed live in the simulator at the current real battery level; the four specific battery-percentage screenshots (76/18/9/4%) aren't individually confirmed live (see "Verification method")
Depends on: 01
Prototype reference: `drawFuelGauge`, `lowFuelLampColor`, `iconPump`, `iconBolt`, `iconSun`

## Goal

Battery shown as a car fuel gauge along the bottom edge, with the Low-Fuel Lamp and a charging icon.

## Scope

- **Segments:** 10 of them at radius `R - 6`, pen 8, spanning 235° to 305° (70° centered on 6 o'clock), drawn counter-clockwise so they fill from left (empty) to right (full).
  - Each segment is 7° wide, trimmed by 0.8° at both ends to leave gaps.
  - Lit count is `round(battery / 10)`. Lit segments are white, unlit dark grey.
- **Low-Fuel Lamp:** a pump icon centered at 223°, radius `R - 16`. Dark grey normally, amber at 20% or below, red at 10% or below. No E/F letters.
- **Charging icon** at 317°, radius `R - 16`:
  - a green bolt while `System.getSystemStats().charging` is true (API 3.0.0)
  - otherwise an amber sun while `solarIntensity` is above zero (API 3.2.0; the value can be null)
  - otherwise nothing
- Draw the icons with `Dc` primitives, ported from the prototype.

## Decisions

- **Module split.** `FuelGauge.mc` owns the segments and the two icon *positions* (Low-Fuel Lamp at 223°, charging icon at 317°); the icon *shapes* (pump, bolt, sun) live in a new `Icons.mc` module shared with tickets 07-08's Readout icons, rather than duplicating drawing code per module.
- **Degree constants as `Float`.** `Geometry.polar(deg, r)` requires `Float` for both parameters (ticket 03 already established this). `FuelGauge.FROM_DEG`/`SPAN_DEG` are declared as `Float` literals (`235.0f`/`70.0f`) so the derived `LAMP_DEG`/`CHARGE_DEG` stay `Float` too, rather than casting at every call site.
- **`solarIntensity` typing.** `System.Stats.solarIntensity` is `Number or Null` per the SDK docs; `FuelGauge.drawChargingIcon` takes it as `Number?` directly (API 3.2.0 is below this project's `minSdkVersion` 3.3.0, so the field is always present; only its value can be null).

## Verification method

Same constraint as tickets 04-05: no Accessibility permission to drive the simulator's Simulation menu, so the four specific battery percentages in this ticket's acceptance list can't be individually staged and screenshotted from here. `FuelGaugeTest.mc` unit-tests `litSegments`/`lowFuelLampColor` against the exact 76/18/9/4% numbers this ticket names, plus the 10%/11%/20%/21% boundaries, which is what actually pins down the rounding and threshold behavior. The simulator screenshot confirms the drawing code runs and is positioned correctly, at whatever battery/solar/charging values the simulator's own default stubs report (a near-full battery with solar intensity > 0, not charging, in this run).

## Acceptance

- [x] 76% shows 8 lit segments and a grey lamp. — `testFuelGaugeLitSegmentsFromTicketScenarios` / `testLowFuelLampColorThresholds`, passing.
- [x] 18% shows 2 lit segments and an amber lamp. — same tests, passing.
- [x] 9% shows 1 lit segment and a red lamp. — same tests, passing.
- [x] 4% shows no lit segments and a red lamp. — same tests, passing.
- [x] The bolt shows while charging. The sun shows only when not charging and solar intensity is above zero. — `FuelGauge.drawChargingIcon`'s `if (charging) ... else if (solarIntensity != null && solarIntensity > 0) ...` makes charging take priority and null-safes the solar check; confirmed live in the simulator (screenshot shows the sun icon, not charging, solar > 0 in the simulator's default state). Not separately confirmed for the charging=true case (see "Verification method").
- [x] Unit tests cover the segment rounding and lamp thresholds, if ticket 01 chose unit tests. — `source/FuelGaugeTest.mc`, all 5 tests passing (`monkeydo -t`).
