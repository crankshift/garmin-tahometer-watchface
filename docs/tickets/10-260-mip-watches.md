# 10: 260×260 MIP watches

Status: open
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

- [ ] The 12 ids are in the manifest, and `monkeyc -e` builds all of them.
- [ ] `fenix6pro` looks right in the simulator.
- [ ] Peak memory for `fenix6pro` and `fenix7pro` is recorded here, each under 85% of its limit, or the watches over it are dropped.
- [ ] The README, `AGENTS.md` and `docs/design.md` list the new watches.
