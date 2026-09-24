# Implementation tickets

The Monkey C port of the design in [`docs/design.md`](../design.md), split into slices. Each slice produces something you can see working in the simulator. The words used here come from [`CONTEXT.md`](../../CONTEXT.md).

The throwaway HTML prototype is [`prototype/index.html`](../../prototype/index.html); open it with `open prototype/index.html`. It holds the exact geometry, colors and icon drawings, and its drawing code goes through a `Dc` shim with the same method names as `Toybox.Graphics.Dc`, so most of it ports line by line. When a ticket and the prototype disagree, the ticket and `docs/design.md` win.

## How to use

- Work one ticket at a time, in dependency order.
- When a ticket is finished, set its `Status:` line to `done` and note anything that changed the design in `docs/design.md`.
- If a ticket turns up a decision the design doesn't cover, record it in the ticket and, if it changes the design, in `docs/design.md`.

## Tickets

| # | Ticket | Depends on |
|---|--------|------------|
| 01 | [Project skeleton and sideload](01-project-skeleton.md) | none |
| 02 | [Numeral bitmap fonts](02-numeral-fonts.md) | 01 |
| 03 | [Tachometer and Minute Style](03-tachometer-minute-style.md) | 01, 02 |
| 04 | [Gear](04-gear.md) | 01, 02 |
| 05 | [Rev Bar](05-rev-bar.md) | 03 |
| 06 | [Fuel Gauge](06-fuel-gauge.md) | 01 |
| 07 | [Slots and first Readouts](07-slots-first-readouts.md) | 02 |
| 08 | [Remaining Readouts](08-remaining-readouts.md) | 07 |
| 09 | [On-watch check](09-on-watch-check.md) | all |

### Multi-device

Specified in [`docs/specs/multi-device.md`](../specs/multi-device.md). All four tickets are worked on one branch, `multi-device`, which merges into `main` when they're done. The version then goes to 1.1.0 for the next Connect IQ Store beta. Check each new screen size in the prototype's Screen picker before running the simulator.

| # | Ticket | Depends on |
|---|--------|------------|
| 10 | [260×260 MIP watches](10-260-mip-watches.md) | none |
| 11 | [Proportional geometry and per-resolution fonts](11-proportional-geometry.md) | none |
| 12 | [240 and 280 MIP watches](12-240-280-mip-watches.md) | 11 |
| 13 | [AMOLED watches](13-amoled-watches.md) | 11 |

## Shared facts

- v1 target: fenix 7 Pro Sapphire Solar 47mm, device id `fenix7pro`, 260×260 round MIP display, 64 colors, Connect IQ API 5.2. Tickets 10 to 13 add more watches (see the multi-device spec).
- Geometry below uses `R = 130` (screen radius) and center `(CX, CY) = (130, 130)`. Angles are Garmin degrees: counter-clockwise from 3 o'clock, as `Dc.drawArc` expects.
- Minute or second to angle: `deg = 180 - 3 * value`. So 0 sits at 9 o'clock, 30 at 12 o'clock and 60 at 3 o'clock.
- Colors: white `0xFFFFFF`, light grey `0xAAAAAA`, dark grey `0x555555`, red `0xFF0000`, amber `0xFFAA00` (`COLOR_YELLOW`), unlit Redline `0x550000`, green `0x00FF00`, blue `0x00AAFF`.
- Settings are edited in the Garmin Connect phone app (`properties.xml` plus `settings.xml`). There is no on-watch settings menu in v1.
