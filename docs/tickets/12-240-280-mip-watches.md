# 12: 240 and 280 MIP watches

Status: done
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

- [x] The prototype at 240 and 280 shows no layout problems.
- [x] The 30 ids are in the manifest, and `monkeyc -e` builds all of them.
- [x] `fenix7s` and `fenix7x` look right in the simulator.
- [x] Peak memory for `fenix6s` and `enduro` is recorded here, under 85% of their limits, or the groups over it are dropped.
- [x] The README, `AGENTS.md` and `docs/design.md` list the new watches.

## Decisions

- **The three fenix 5 Plus watches stay.** `fenix5plus`, `fenix5splus` and `fenix5xplus` each have two part numbers in the SDK: current firmware (Connect IQ 3.3.3, built) and old firmware (3.2.8, below our `minSdkVersion` of 3.3.0). `monkeyc -e` warns that it is ignoring the 3.2.8 part numbers and carries on. Nothing to fix: owners on old firmware can't install the face until they update. The README says so.
- **No smaller fonts.** Both memory groups are far under 85%, so the fonts from ticket 11 stay as they are for 240 and 280.

## Results

Done on 2026-09-24.

- **Prototype.** Checked first, before any simulator run. The Screen picker at 240 (fenix 7S) and 280 (fenix 7X) shows the Tachometer, Gear, Slots, Fuel Gauge and Tip in proportion, with nothing clipped or overlapping.
- **Build.** `monkeyc -e` builds all 43 products in the manifest (the 30 new ids, plus the 13 from v1 and ticket 10) and ends with `BUILD SUCCESSFUL`, 84 of 84 part numbers. The warnings are the launcher icon ones for the three 35×35 watches from ticket 10 (each printed twice), and the ignored old-firmware part numbers described above.
- **Unit tests.** 65 of 65 pass on `fenix7s`, `fenix7x`, `fenix6s` and `enduro`.
- **Look check.** Screenshots of the simulator window on `fenix7s` (240) and `fenix7x` (280) match the prototype at the same size: layout and proportions agree, and only the digit shapes differ, since the prototype's font isn't Barlow. The Slot values are simulator data (0 steps, no heart rate).
- **Peak memory.** The "Peak Memory" line of the simulator's Active Memory window (File > View Memory). The simulator's own limit is a little below the watch face limit in the device profile, so the share is against the smaller figure.

  | Device | Watch face limit | Simulator limit | Peak | Share of the simulator limit |
  |---|---|---|---|---|
  | `fenix6s` | 96 KB | 91.8 kB | 32.9 kB | 36% |
  | `enduro` | 112 KB | 107.8 kB | 33.7 kB | 31% |

  Both are far under 85%, so no group is dropped. `fenix6s` stands for every 96 KB watch, and `enduro` for the 112 KB one. On both, the memory view lists 15,681 bytes of code and 5,046 bytes of data.
