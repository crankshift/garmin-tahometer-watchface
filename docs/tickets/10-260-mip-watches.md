# 10: 260×260 MIP watches

Status: done
Depends on: none
Spec: [`docs/specs/multi-device.md`](../specs/multi-device.md)

## Goal

The face runs on every in-scope watch with a 260×260 round MIP screen. The screen matches `fenix7pro`, so no layout work is needed. This ticket just adds the watches and checks memory on the tightest one.

## Scope

- Add these 12 product ids to `manifest.xml`, next to `fenix7pro`:
  `fenix6`, `fenix6pro`, `fenix7`, `fenix7pronowifi`, `fenix8solar47mm`, `fenix9prosolar47mm`, `fr255`, `fr255m`, `fr955`, `legacyherofirstavenger`, `legacysagadarthvader`, `vivoactive4`.
- Build the package for every product (`monkeyc -e`) and fix anything that fails. The code already compiled cleanly for `fenix6pro` during the planning session (API 3.4, 17 KB of code and data according to `--build-stats 0`).
- Check the build output for launcher icon warnings. Some 260 watches want 35×35, and ours is 40×40.
- Simulator:
  - A look check on `fenix6pro`, the only API 3.x rendering check at this size.
  - Peak memory on `fenix6pro` (112 KB limit) and `fenix7pro` (128 KB limit; ticket 09 never recorded it). The maintainer opens File > View Memory, and the agent reads it from a screenshot of the simulator window (see the spec's "Verification").
  - If `fenix6` / `fenix6pro` go over 85% of their limit, drop them from the manifest and record it here.
- Update the device facts that name only the fenix 7 Pro: the README (the "Built for" line), the target line in `AGENTS.md`, and "Target" in `docs/design.md`.

## Acceptance

- [x] The 12 ids are in the manifest, and `monkeyc -e` builds all of them.
- [x] `fenix6pro` looks right in the simulator.
- [x] Peak memory for `fenix6pro` and `fenix7pro` is recorded here, each under 85% of its limit, or the watches over it are dropped.
- [x] The README, `AGENTS.md` and `docs/design.md` list the new watches.

## Decisions

- **Launcher icon.** Three watches want a 35×35 launcher icon: `vivoactive4`, `legacyherofirstavenger` and `legacysagadarthvader`. The build warns that our 40×40 icon "will be scaled to the target size" and carries on. I left it as is: it is a warning only, and a per-device icon would add another resource folder for tickets 11 to 13 to work around.
- **`fenix6` stays.** It has the same 112 KB watch face limit as `fenix6pro` in its device profile, and `fenix6pro` is far under 85%, so it was not measured on its own.
- **`AGENTS.md` points to the manifest.** Its target line says "the 12 other watches with the same screen listed in `manifest.xml`" instead of naming them. The README names them and `docs/design.md` lists the ids. Tickets 12 and 13 add about 78 more ids, so `AGENTS.md` should not need another edit each time.

## Results

Done on 2026-09-24.

- **Build.** `monkeyc -e` builds all 13 products (the 12 new ids and `fenix7pro`) with `BUILD SUCCESSFUL`. The unit tests pass on `fenix6pro` and `fenix7pro` (43 of 43 on each).
- **Look check.** `fenix6pro` (API 3.4.5) renders the same face as `fenix7pro`. The sun next to the Fuel Gauge is the solar-intensity icon, which the simulator reports as above zero.
- **Peak memory.** The "Peak Memory" line of the simulator's Active Memory window (File > View Memory). The simulator's own limit is a little below the watch face limit in the device profile, so the share is against the smaller figure.

  | Device | Watch face limit | Simulator limit | Peak | Share of the simulator limit |
  |---|---|---|---|---|
  | `fenix6pro` | 112 KB | 107.8 kB | 28.6 kB | 27% |
  | `fenix7pro` | 128 KB | 123.8 kB | 21.4 kB | 17% |

  Both are far under 85%, so no watch is dropped. `--build-stats 0` gives 12.7 KB of code and 4.1 KB of data on `fenix6pro`, and 9.6 KB and 2.3 KB on `fenix7pro`.
