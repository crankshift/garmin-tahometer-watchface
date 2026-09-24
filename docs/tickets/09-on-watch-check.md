# 09: On-watch check

Status: done: closed as tested on 2026-09-24. The maintainer confirmed that the face runs and works on the real fenix 7 Pro. The measurement items were dropped (see "Comments").
Depends on: 01 to 08

## Goal

Confirm the face works on the real watch, and collect the tweaks that only show up on the wrist.

## Scope

- Sideload the full face and wear it for two to three days.
- Battery: compare daily drain against a stock Garmin face, once with Always-on Rev Bar off and once with it on.
- Memory: compare peak memory in the simulator's memory view against the limit recorded in ticket 01.
- Readability in sunlight and indoors, on the MIP screen:
  - amber against red at the Redline
  - Low-Fuel Lamp colors
  - dark grey (`0x555555`) unlit segments
  - the small weekday and AM/PM text
- Decide whether the up-to-a-minute frozen Rev Bar after a budget overrun (see ticket 05) is acceptable.
- Write the agreed tweaks into `docs/design.md`. Open follow-up tickets for anything bigger than a constant change.
- Delete `prototype/` from main, since the Monkey C code is now the reference. Remove the links to it from `docs/design.md` and `docs/tickets/README.md`.

## Acceptance

- [x] ~~Battery drain is measured for both Rev Bar settings and noted here.~~ Dropped: the maintainer's real-watch check covers only "runs and works".
- [x] ~~Peak memory is under the limit with headroom, and noted here.~~ Moved to ticket 10, which measures `fenix7pro` along with the new watches.
- [x] ~~The tweak list is written down, and `docs/design.md` is updated.~~ Dropped: no tweaks came up on the watch.
- [x] ~~`prototype/` is gone from main.~~ Dropped: the prototype stays. It renders the README and Store images, and its Screen picker checks layouts for tickets 10 to 13.

## Comments

2026-09-24, while planning multi-device support: the maintainer tested the sideloaded face on their fenix 7 Pro, and it runs and works. They only check that; battery drain, sunlight readability and similar measurements aren't part of their testing. So this ticket closes on that result, and the measurement items above are dropped or moved.
