# 03: Tachometer and Minute Style

Status: partial: implemented and ported line-by-line from the prototype; can't verify in the simulator until the SDK is installed (see ticket 01)
Depends on: 01, 02
Prototype reference: `drawTachometer`, `drawNeedle`

## Goal

The Tachometer scale across the top half of the face, with all three Minute Styles and the Minute Style setting.

## Scope

Use `dc.setAntiAlias(true)` (API 3.2.0). The minute always moves in whole-minute steps.

- **Unlit Redline:** always draw an arc from minute 50 to 60 at radius `R - 6`, pen 8, in `0x550000`.
- **Sweep** (Sweep and Sweep + Tip styles): same radius and pen. Amber from minute 0 to `min(m, 50)`, then red from 50 to `m`. Nothing is drawn at minute 0.
- **Ticks** for minutes 0 to 60, with their outer end at radius `R - 11`:
  - every 10 minutes: length 12, pen 3
  - every 5 minutes: length 8, pen 2
  - every minute: length 4, pen 1
  - Ticks at 50 and above are red, the rest white.
- **Numerals** 0 to 6, centered at radius `R - 34`, in the Tachometer numeral font from ticket 02. 5 and 6 are red, the rest white. No unit label.
- **Tip** (Sweep + Tip only): a white line, pen 3, from radius `R - 19` to `R` at the current minute.
- **Needle** (Needle only): a filled polygon from radius `R - 46`, just outside the Rev Bar, to `R - 8`. Half-width 2.5 px at the base and 1 px at the tip. Amber, red from minute 50. No center hub, so it never crosses the Gear.
- **Setting** "Minute Style": a list with Needle, Sweep, and Sweep + Tip. Default Sweep + Tip. Changing it in the app redraws the face without restarting it.

## Decisions

- **Port structure.** `source/Tachometer.mc` mirrors the prototype's `drawTachometer`/`drawNeedle` almost line for line, plus two small pure helpers pulled out for testability that the prototype only had inline: `tickSpec(minute)` (the `i % 10 === 0 ? TICKS.major : ...` chain) and `isRedline(value)` (the `>= 50` / `n >= 5` checks, generalized to one function since numerals pass `n * 10`).
- **Property type — corrected after the SDK became available (see docs/tickets/04-gear.md and later).** Originally `MinuteStyle` was a `string` property so `settings.xml`'s `listEntry` values, the Monkey C code and the prototype could share literal strings. Building against the real SDK (ticket 04-08 session) surfaced a hard compiler error, `Unable to process 'setting' resources: For input string: "needle"`. The SDK's own `Properties_and_App_Settings` doc has a property-type/setting-type compatibility table: a `settingConfig type="list"` is only valid on a `number` property (`string` properties only support `alphaNumeric`/`phone`/`email`/`url`/`password`). So `MinuteStyle` is now a `number` property (`0`/`1`/`2`), with `Tachometer.STYLE_NEEDLE`/`STYLE_SWEEP`/`STYLE_SWEEP_TIP` as `Number` constants compared with `==` instead of `.equals()`. Every other list setting added in tickets 04-08 (Weather temperature, the four Slot Readout settings) follows the same numeric-property pattern for the same reason.
- **Settings-change redraw.** Implemented via `Application.AppBase.onSettingsChanged()` calling `WatchUi.requestUpdate()`, the standard Connect IQ mechanism — no restart needed, matches the design's requirement directly.
- **Scope.** Only the Tachometer scale and the three Minute Styles are drawn in this slice. The Gear, Rev Bar, Slots and Fuel Gauge from the prototype's `drawFace` aren't called yet (tickets 04-08), so `TachometerWatchFaceView.onUpdate` currently just clears the screen and calls `Tachometer.drawTachometer` + `Tachometer.drawNeedle`.

## Acceptance

- [ ] At 14:37 the Sweep ends at 3.7 on the scale, with the Tip at the same spot. — blocked: needs the simulator (see ticket 01). Traced by hand instead: `drawSweep(dc, 37)` draws amber from `minuteDeg(0)` to `minuteDeg(37)`; `drawTip` (Sweep + Tip only) draws at `minuteDeg(37)` — same angle, matching the ticket's expected 3.7 mark.
- [ ] At 20:52 the Sweep is amber to 5, then red to 5.2. — blocked, same reason. Traced by hand: `drawSweep(dc, 52)` draws amber `minuteDeg(0)` to `minuteDeg(50)` (5 on the scale), then red `minuteDeg(50)` to `minuteDeg(52)` (5.2 on the scale) — matches.
- [ ] At minute 0 no Sweep is drawn, and the Tip sits on 0. — blocked, same reason. Traced by hand: `drawSweep` returns immediately when `minute <= 0`; `drawTip` still runs (it isn't gated on minute) and draws at `minuteDeg(0)`, which is minute 0 on the scale — matches.
- [ ] In Needle style, nothing is drawn inside radius `R - 46`. — blocked, same reason. Traced by hand: `drawNeedle`'s polygon points all use radius `NEEDLE_R0 = R - 46` as the innermost radius (the base), so nothing is drawn closer to center than that — matches.
- [ ] Changing Minute Style in the simulator's app settings editor changes the face. — blocked: needs the simulator.
