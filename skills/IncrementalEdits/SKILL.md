---
name: IncrementalEdits
description: "Revise an existing file as discrete reviewable hunks, never a wholesale overwrite. USE WHEN editing, rewriting, or revising a document, note, config, or file the user will review, especially one they have already hand-edited."
version: 0.1.0
---

# IncrementalEdits

When you revise a file the user will review, change it hunk by hunk with targeted edits, one concern per edit. A single write that replaces the whole file is the wrong tool whenever discrete edits would do.

- One coherent change per edit: a section, a corrected claim, a reworded caveat. Each hunk stays separately reviewable and separately revertable.
- Touch only the span the change needs; leave the surrounding text byte-for-byte intact. A full-file write silently reverts hand-edits you never meant to touch.
- The diff is the review surface. A hundred-line replacement hides the three lines that matter; a sequence of small edits shows exactly what moved.
- This holds even when the content is already approved. Approval settles WHAT changes; hunk-by-hunk settles HOW it lands, so the diff stays legible.

## Red Flags

| Thought                                            | Reality                                                                   |
| -------------------------------------------------- | ------------------------------------------------------------------------- |
| "I'll just rewrite the whole file, it's cleaner"    | The reviewer loses the diff and their own edits. Edit the spans that move. |
| "The content is pre-approved, a full write is fine" | Approval is about content, not delivery. Land it as hunks anyway.          |
| "Many small edits are noisy"                         | Small edits are the review surface. One concern per edit beats one blob.   |

## Constraints

- Reserve full-file writes for new files, or a rewrite the user explicitly asked to be wholesale
- One concern per edit; never bundle unrelated changes into one hunk
- Preserve the user's surrounding hand-edits verbatim
