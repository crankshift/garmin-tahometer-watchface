# 01: Project skeleton and sideload

Status: open
Depends on: none
Blocks: every other ticket

## Goal

An empty watch face for the fenix 7 Pro that builds, runs in the Connect IQ simulator, and installs on the real watch.

## Scope

- Install the Connect IQ SDK Manager, the latest SDK, and the `fenix7pro` device profile. The Sapphire Solar has Wi-Fi, so it is `fenix7pro`, not `fenix7pronowifi`.
- Install VS Code with the Monkey C extension and generate a developer key.
- Create a watch face project: manifest type `watchface`, product `fenix7pro`, and a minimum API level that covers what later tickets use (3.3.0 is enough for everything in the design).
- The view clears the screen to black and draws a small debug text so it's obvious the face is running.
- Build a `.prg` and sideload it over USB into `GARMIN/APPS` on the watch. On macOS the fenix 7 connects over MTP, so you need a tool such as OpenMTP.
- Find the watch face memory limit for `fenix7pro` in the SDK's device files (the `compiler.json` in the device folder) and write it down in this ticket. Garmin doesn't publish the number, so it has to come from the SDK.

## Decisions to make here

These are the port questions the design session left open:

- **Source layout.** Suggested: one module or class per glossary term (Tachometer, Gear, Rev Bar, Fuel Gauge, Slots, Readouts), so the code reads like `CONTEXT.md`.
- **Testing.** Suggested: Monkey C `(:test)` unit tests for the pure logic (Fuel Gauge segment rounding, Gear text, next sun event, temperature formatting), plus visual checks in the simulator for drawing.
- **Geometry helpers.** Suggested: port the prototype's `minuteDeg` and `polar` helpers as they are, so constants from the prototype can be copied across.

Record the choices in this ticket. Add an ADR under `docs/adr/` only if a choice is hard to reverse and would surprise a later reader.

## Acceptance

- [ ] The project builds without warnings for `fenix7pro`.
- [ ] The face runs in the simulator on the `fenix7pro` profile.
- [ ] After sideloading, the face appears on the watch and can be selected.
- [ ] The memory limit is recorded in this ticket.
- [ ] The source layout and testing approach are recorded in this ticket.
