# 12: 240 and 280 MIP watches

Status: open
Depends on: 11
Spec: [`docs/specs/multi-device.md`](../specs/multi-device.md)
Prototype reference: the Screen picker at 240 and 280

## Goal

The face runs on every in-scope watch with a 240×240 or 280×280 round MIP screen, using the scaling and fonts from ticket 11.

## Scope

- Check the layout in the prototype at 240 and 280 first, before any simulator run.
- Add these product ids to `manifest.xml`:
  - **240 (21 ids):** `descentmk2s`, `fenix5plus`, `fenix5splus`, `fenix5xplus`, `fenix6s`, `fenix6spro`, `fenix7s`, `fenix7spro`, `fr245`, `fr245m`, `fr745`, `fr945`, `fr945lte`, `marqadventurer`, `marqathlete`, `marqaviator`, `marqcaptain`, `marqcommander`, `marqdriver`, `marqexpedition`, `marqgolfer`.
  - **280 (9 ids):** `descentmk2`, `enduro`, `enduro3`, `fenix6xpro`, `fenix7x`, `fenix7xpro`, `fenix7xpronowifi`, `fenix8solar51mm`, `fenix9prosolar51mm`.
- Build the package for every product (`monkeyc -e`).
- Simulator:
  - Look checks on `fenix7s` (240) and `fenix7x` (280).
  - Peak memory on `fenix6s`, which has the smallest limit of all (96 KB) and stands for every 96 KB watch, and on `enduro` (112 KB). The maintainer opens the memory view, and the agent reads it from a screenshot of the simulator window.
  - If a group goes over 85% of its limit, try smaller fonts for that resolution first. If it's still over, drop the group and record it here.
- Update the device lists in the README, `AGENTS.md` and `docs/design.md`.

## Acceptance

- [ ] The prototype at 240 and 280 shows no layout problems.
- [ ] The 30 ids are in the manifest, and `monkeyc -e` builds all of them.
- [ ] `fenix7s` and `fenix7x` look right in the simulator.
- [ ] Peak memory for `fenix6s` and `enduro` is recorded here, under 85% of their limits, or the groups over it are dropped.
- [ ] The README, `AGENTS.md` and `docs/design.md` list the new watches.
