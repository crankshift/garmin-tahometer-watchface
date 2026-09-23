# Issue tracker: Local Markdown

Tickets and specs for this repo are markdown files committed to `main`. Planned work goes here, not into GitHub Issues.

## Conventions

- Each ticket is its own file, `docs/tickets/<NN>-<slug>.md`. Numbering continues across features (v1 used 01 to 09).
- `docs/tickets/README.md` lists every ticket in a table with its dependencies. Add a row for each new ticket.
- A feature's spec is `docs/specs/<feature-slug>.md`. The v1 spec is `docs/design.md`.
- Near the top of each ticket are a `Status:` line (`open`, `done`, or a triage role from `triage-labels.md`), a `Depends on:` line (ticket numbers, or `none`), and optionally a `Blocks:` line.
- A ticket is unblocked once every ticket in its `Depends on:` line is `done`. Work tickets in dependency order, and set `Status: done` when one is finished.
- Record decisions made while working a ticket under its `## Decisions` heading. If a decision changes the design, record it in the spec too.
- Add comments and conversation history at the bottom of the file, under a `## Comments` heading.

## When a skill says "publish to the issue tracker"

Create the next numbered file in `docs/tickets/` and add its row to `docs/tickets/README.md`.

## When a skill says "fetch the relevant ticket"

Read the file at the referenced path. The user will normally pass the path or the ticket number directly.

## Wayfinding operations

Used by `/wayfinder`. The **map** is a file with one **child** file per ticket.

- **Map**: `docs/wayfinder/<effort>/map.md` (the Notes / Decisions-so-far / Fog body).
- **Child ticket**: `docs/wayfinder/<effort>/issues/NN-<slug>.md`, numbered from `01`, with the question in the body. A `Type:` line records the ticket type (`research`/`prototype`/`grilling`/`task`); a `Status:` line records `claimed`/`resolved`.
- **Blocking**: a `Blocked by: NN, NN` line near the top. A ticket is unblocked when every file it lists is `resolved`.
- **Frontier**: scan `docs/wayfinder/<effort>/issues/` for files that are open, unblocked, and unclaimed; first by number wins.
- **Claim**: set `Status: claimed` and save before any work.
- **Resolve**: append the answer under an `## Answer` heading, set `Status: resolved`, then append a context pointer (gist + link) to the map's Decisions-so-far in `map.md`.
