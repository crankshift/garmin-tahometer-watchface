# Triage Labels

The skills speak in terms of five canonical triage roles. This repo's tracker is local markdown, so a ticket's triage role is the value of its `Status:` line. This file maps each role to that value.

| Label in mattpocock/skills | `Status:` value in our tickets | Meaning                                  |
| -------------------------- | ------------------------------ | ---------------------------------------- |
| `needs-triage`             | `needs-triage`                 | Maintainer needs to evaluate this issue  |
| `needs-info`               | `needs-info`                   | Waiting on reporter for more information |
| `ready-for-agent`          | `ready-for-agent`              | Fully specified, ready for an AFK agent  |
| `ready-for-human`          | `ready-for-human`              | Requires human implementation            |
| `wontfix`                  | `wontfix`                      | Will not be actioned                     |

When a skill mentions a role (e.g. "apply the AFK-ready triage label"), set the ticket's `Status:` line to the corresponding value from this table.

Edit the right-hand column to match whatever vocabulary you actually use.
