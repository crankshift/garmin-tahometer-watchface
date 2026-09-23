# 06: Fuel Gauge

Status: open
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

## Acceptance

- [ ] 76% shows 8 lit segments and a grey lamp.
- [ ] 18% shows 2 lit segments and an amber lamp.
- [ ] 9% shows 1 lit segment and a red lamp.
- [ ] 4% shows no lit segments and a red lamp.
- [ ] The bolt shows while charging. The sun shows only when not charging and solar intensity is above zero.
- [ ] Unit tests cover the segment rounding and lamp thresholds, if ticket 01 chose unit tests.
