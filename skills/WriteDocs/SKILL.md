---
name: WriteDocs
version: 0.1.0
description: "Author project documentation that future humans (and AI sessions) actually read. Covers TLDRs for tools, READMEs, runbooks, journals. USE WHEN write documentation, create tldr, tool one-pager, document a cli, write readme, runbook, journal entry, capture knowledge about a tool, distill a session into reusable notes."
---

# WriteDocs

Documentation is a contract with the reader. The reader is usually a future-you or a future AI session that has lost the surrounding context. Good docs collapse what would otherwise be a fresh round of trial and error into a single read. Bad docs are noise — they bloat the repo, drift from reality, and train readers to skip docs entirely.

This skill collects the shapes that have proven worth the maintenance cost. Pick the matching companion for the doc you're about to write; if none fits, the work probably belongs in code comments, a commit message, or an ADR rather than a new doc file.

## Doc Types

| Type     | Trigger                                                                              | Companion           |
| -------- | ------------------------------------------------------------------------------------ | ------------------- |
| TLDR     | "write tldr", "tool one-pager", "document a cli", "distill a tool from this session" | [@Tldr.md](Tldr.md) |

Other types (README, runbook, journal, migration guide) live in adjacent rules or are queued for future companions; add a row here when a new companion is authored.

## Red Flags

| Thought                                                  | Reality                                                                                  |
| -------------------------------------------------------- | ---------------------------------------------------------------------------------------- |
| "I'll document every flag and option"                    | Comprehensive ≠ useful. The reader needs the 80% path, not the man page.                  |
| "Better to over-document than under-document"            | Wrong volume kills docs. Over-detail trains readers to skip; under-detail makes them grep. |
| "I'll add a `## Future Work` section"                    | Future-work sections rot. Track in a backlog file, not in the doc.                        |
| "This needs a top-level overview section"                | If the first paragraph isn't already the overview, the doc is misstructured.              |
| "Let me link to upstream docs and call it done"          | Docs that only link out fail when upstream restructures. Capture the load-bearing bits.   |
| "I'll keep this in sync with the code"                   | Anything inline that mirrors the code drifts. Reference by path/line; restate sparingly.  |

## Constraints

- Every doc file has a clear single audience: the maintainer, a contributor, an AI session, or an external user. Mixing audiences is the most common doc failure mode.
- Concrete examples beat abstract descriptions. A real invocation > a parameter list.
- Tables for shapes that fit a table (keybindings, flags, file → purpose). Prose for everything else.
- When the doc and the code disagree, the code is right; update the doc and add a verification command if possible.
- Date the doc only when chronology matters (journals, incident reports). Otherwise dates are clutter that becomes wrong.

## Sources

- [Diátaxis](https://diataxis.fr) — tutorial / how-to / reference / explanation as the canonical four doc types
- [Write the Docs](https://www.writethedocs.org/guide/) — community guide to doc writing
- [Google Developer Documentation Style Guide](https://developers.google.com/style)
