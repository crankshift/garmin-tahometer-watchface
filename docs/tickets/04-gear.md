# 04: Gear

Status: done
Depends on: 01, 02
Prototype reference: `drawGear`, `gearText`

## Goal

The hour as a large number inside the Tachometer.

## Scope

- Centered both ways at `(CX, CY - 36)`, white, in the Gear font from ticket 02.
- Follows `System.getDeviceSettings().is24Hour`.
  - 24-hour: hour 0 to 23, no leading zero.
  - 12-hour: hour 1 to 12, no leading zero. A small light-grey `AM` or `PM` sits centered below the Gear, `capHeight / 2 + 9` px below its center.

## Decisions

- **Variant.** Only variant B's layout exists in this codebase (variant A, Gear below center, lost the design grilling — see `docs/design.md` "Gear"), so `Gear.mc` ports only the `ampmBelow: true` branch of the prototype's `drawGear`; the `else` branch (AM/PM beside the Gear) is dead code in the prototype for this project and isn't carried over.
- **Font height.** The prototype's `dc.fontHeight(font)` (a `Dc` shim method) is `Graphics.Dc.getFontHeight(font)` on the real API.
- **Scope note (see ticket 01's "Resolved" section).** Building this ticket against the real SDK is what surfaced the `getInitialView` and `fillPolygon` type errors and the `MinuteStyle` property/setting-type bug — fixed there, not here, since they were pre-existing bugs in tickets 01-03's code, not something introduced by the Gear.

## Verification method

The SDK is installed this session (see ticket 01), but this environment has no Accessibility/Screen Recording permission for UI scripting (`osascript`'s System Events gets `-1719 not allowed assistive access`), which is the same root cause ticket 01 hit trying to drive the SdkManager GUI. That means the simulator's Simulation menu (set a custom time, battery level, etc.) can't be driven from here — only `monkeyc`/`monkeydo` (build, unit tests, run) and `screencapture` (screenshot whatever the simulator shows, i.e. real wall-clock time and whatever the simulator's default sensor stubs report) are usable non-interactively. So scenario-specific acceptance items (a specific hour, a specific battery %) are verified by unit test against the ticket's own numbers, the same "trace by hand" approach ticket 03 used, except here the trace is an actual passing test run, not hand-tracing. Live screenshots confirm the drawing code runs, is positioned correctly, and doesn't crash or overlap other elements, using whatever time the simulator happens to show.

## Acceptance

- [x] At 00:xx in 24-hour mode the Gear shows `0`. — `testGearTextMidnight24Hour` (`source/GearTest.mc`), passing.
- [x] At 12:xx in 12-hour mode the Gear shows `12` with `PM`. At 00:xx it shows `12` with `AM`. — `testGearTextNoonTwelveHourStaysTwelve` and `testGearTextMidnight12Hour` cover the `12` text; `testIsAMBeforeNoon` covers the AM/PM choice at hour 0 and 12. All passing.
- [x] Two-digit hours stay inside the Rev Bar ring, and AM/PM doesn't touch the Slot row. — confirmed live in the simulator at 08:40 (screenshot: single digit, well clear); geometry check for two digits: the Gear font's widest two glyphs (`gear.fnt`, ticket 02) are ~41 px wide each, so ~85 px total at `CY - 36`, centered — well inside the Rev Bar radius (`R - 50 = 80` px) and nowhere near the Slot row at `CY + 38`. Not re-confirmed with an actual two-digit hour screenshot (see "Verification method").
- [x] Unit tests cover the Gear text for 0, 11, 12, 13 and 23 in both modes, if ticket 01 chose unit tests. — `source/GearTest.mc`, all 7 tests passing (`monkeydo -t`).
