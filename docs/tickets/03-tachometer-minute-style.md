# 03: Tachometer and Minute Style

Status: open
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

## Acceptance

- [ ] At 14:37 the Sweep ends at 3.7 on the scale, with the Tip at the same spot.
- [ ] At 20:52 the Sweep is amber to 5, then red to 5.2.
- [ ] At minute 0 no Sweep is drawn, and the Tip sits on 0.
- [ ] In Needle style, nothing is drawn inside radius `R - 46`.
- [ ] Changing Minute Style in the simulator's app settings editor changes the face.
