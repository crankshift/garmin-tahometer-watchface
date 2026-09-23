# 04: Gear

Status: open
Depends on: 01, 02
Prototype reference: `drawGear`, `gearText`

## Goal

The hour as a large number inside the Tachometer.

## Scope

- Centered both ways at `(CX, CY - 36)`, white, in the Gear font from ticket 02.
- Follows `System.getDeviceSettings().is24Hour`.
  - 24-hour: hour 0 to 23, no leading zero.
  - 12-hour: hour 1 to 12, no leading zero. A small light-grey `AM` or `PM` sits centered below the Gear, `capHeight / 2 + 9` px below its center.

## Acceptance

- [ ] At 00:xx in 24-hour mode the Gear shows `0`.
- [ ] At 12:xx in 12-hour mode the Gear shows `12` with `PM`. At 00:xx it shows `12` with `AM`.
- [ ] Two-digit hours stay inside the Rev Bar ring, and AM/PM doesn't touch the Slot row.
- [ ] Unit tests cover the Gear text for 0, 11, 12, 13 and 23 in both modes, if ticket 01 chose unit tests.
