---
name: ProjectBacklog
version: 0.1.0
description: "Capture, list, update, and close repo-local backlog items as Obsidian Tasks lines in dated daily files under docs/todos/. USE WHEN capture todo, project todo, project backlog, repo backlog, backlog item, list todos, todo capture, new todo, close todo, or local issue tracking without GitHub."
---

# ProjectBacklog

Repo-local backlog inspired by [todo.txt][TODOTXT], stored as [Obsidian Tasks][OBS] checkbox lines with [Dataview][DV] inline fields. One markdown file per capture day, multiple todos per file. Queryable from Obsidian (Tasks plugin and Dataview), grep-able from the shell. Use this when an idea, defect, or follow-up should outlive the conversation but is too small for an ADR and too project-specific for the personal vault backlog.

## Conventions

### Location

`docs/todos/YYYY-MM-DD.md` — one file per capture day. Daily files are append-only logs. The date in the filename IS the created date for every item in the file.

### Item format

Each todo is one Obsidian Tasks checkbox line followed by optional indented sub-bullets for context, acceptance criteria, and links.

```markdown
- [ ] Short imperative description [priority:: high] [id:: 0001] #tag1 #tag2
    - Why this matters in one sentence.
    - Acceptance: bullet list of conditions for closing.
    - Related: [[0004 Some ADR]], #123, links to other todos.
```

### Status markers

| Marker | Meaning |
| ------ | ------- |
| `- [ ]` | open |
| `- [/]` | in progress |
| `- [x]` | done |
| `- [-]` | won't do / cancelled |

### Inline fields

Dataview `[key:: value]` syntax. Place after the description, before tags.

| Field | Values |
| ----- | ------ |
| `[priority:: ...]` | `highest`, `high`, `medium`, `low`, `lowest` (default: `medium`) |
| `[id:: NNNN]` | required — 4-digit zero-padded stable id, unique across the project |
| `[due:: YYYY-MM-DD]` | optional deadline |
| `[start:: YYYY-MM-DD]` | optional earliest start date |
| `[scheduled:: YYYY-MM-DD]` | optional scheduled date |
| `[completion:: YYYY-MM-DD]` | set when status flips to `[x]` |

The created date is implicit in the filename — never restate it as an inline field.

### File layout

```markdown
# Todos — 2026-04-27

- [ ] First todo of the day [priority:: high] [id:: 0002] #app
    - Acceptance bullets.

- [ ] Second todo of the day [priority:: medium] [id:: 0001] #docs
    - ...
```

Newest item at the top of the file. Items captured on later days go in their own dated files. Closed items stay in their original file with `- [x]` and `[completion:: YYYY-MM-DD]` — never deleted, never moved.

## Workflow Routing

| Workflow | Trigger | Section |
| -------- | ------- | ------- |
| Capture  | "capture todo", "new todo", "add backlog item" | [Capture](#capture-workflow) |
| List     | "list todos", "show backlog", "open todos" | [List](#list-workflow) |
| Update   | "update todo", "mark in-progress", "set priority" | [Update](#update-workflow) |
| Close    | "close todo", "mark done", "won't do" | [Close](#close-workflow) |

## Capture Workflow

1. If `docs/todos/` does not exist, create it.

2. Resolve today's date and target file `docs/todos/YYYY-MM-DD.md`. If the file does not exist, create it with a `# Todos — YYYY-MM-DD` heading.

3. Extract from the user input: short imperative description, priority (default `medium`), tags, optional acceptance criteria.

4. Scan all existing daily files for description overlap. If a related open item exists, propose updating it instead of duplicating.

5. Assign the next 4-digit id (max existing `[id:: NNNN]` across all daily files + 1, starting at `0001`).

6. Insert the new item at the top of today's file with `- [ ]` status, the assigned id, and tags. Add indented sub-bullets only if acceptance criteria or context are non-trivial.

7. Report the id, file path, and line written.

## List Workflow

1. Glob `docs/todos/*.md`. Read all items.

2. Default view: open + in-progress, grouped by priority. Show id, description, age (days since created, derived from filename).

3. On request, filter by tag, priority, status, or date range.

## Update Workflow

1. Identify the item by id (`[id:: NNNN]`) or description fragment.

2. Edit the line in place — flip the checkbox, change priority, add/remove tags, append a sub-bullet.

3. Status transitions: `[ ]` → `[/]` → `[x]`. `[-]` is terminal. Reopening requires `[x]` → `[ ]` with a sub-bullet explaining why.

4. Never edit the `[id:: NNNN]` once assigned. Never move the item to a different daily file.

## Close Workflow

1. Set the checkbox to `[x]` (done) or `[-]` (won't do).

2. Append `[completion:: YYYY-MM-DD]` for completed items.

3. Add a sub-bullet noting the closing commit, PR, or rationale.

4. Leave the item in its original daily file — the file represents the day the work was captured, not the day it closed.

## Constraints

- One file per capture day. Never split items by status, priority, or tag across files.
- The filename date is canonical for `created`. Never duplicate it as an inline field.
- Every item carries a stable `[id:: NNNN]` so external references (commits, ADRs, other todos) survive description edits.
- Closed items stay in their original daily file. Never delete, never move.
- Sub-bullets are optional but encouraged when acceptance criteria are non-trivial. Trivial todos can be a single line.
- Use Dataview inline-field syntax (`[key:: value]`) for metadata, not emojis. The plain-text form is git-diff-friendly and survives non-Obsidian tooling.
- Don't introduce non-standard inline fields. Stick to Obsidian Tasks-recognised keys so third-party queries keep working.

[TODOTXT]: https://github.com/todotxt/todo.txt
[OBS]: https://publish.obsidian.md/tasks/
[DV]: https://blacksmithgu.github.io/obsidian-dataview/annotation/add-metadata/

@Example.md
