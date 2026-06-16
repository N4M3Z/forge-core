---
name: SessionHandoff
version: 0.1.0
description: "Continue work from another agent's session — auto-detect the most relevant saved session, read its transcript, summarize, and pick up the work. USE WHEN continue from another agent, hand off a session, pick up where codex or gemini left off, summarize a saved session or checkpoint, inspect recent sessions. Not for searching old work by topic — use SessionSearch for that."
allowed-tools: Bash, Read
upstream: https://github.com/entireio/skills/blob/main/skills/session-handoff/SKILL.md
---

# SessionHandoff

Hand off a captured agent session into this one: detect the right session, read its transcript, summarize, continue the work. Backend commands and the checkpoint-id variant live in [@Entire.md](Entire.md).

## Response Format

Begin the first response to this skill invocation with the line:

`Entire Session Handoff:`

followed by a blank line, then the content. Apply the header to the **first response of the invocation only** — not on follow-up turns and not on error / early-exit responses (no sessions found, transcript missing). Its presence signals the skill ran and produced real output. The "Unanswered Question" branch still gets the header.

## STOP — Read these rules before doing ANYTHING

1. **Do NOT ask clarifying questions.** Auto-detect the session and read the transcript.
2. **Do NOT run** `git log`, `git status`, `git branch`, `ps aux`, or any other exploratory commands. Use only the backend CLI commands listed in [@Entire.md](Entire.md).
3. **Do NOT say** "Would you like me to continue?" or "Let me know if you want me to pick this up." Just read the transcript and start working. Exception: if the previous agent asked the user a question that was never answered, you MUST ask the user that question before proceeding.

## Flow: Active session handoff (default — also covers bare invocation and "current"/"active")

### Step 1: Resolve the canonical worktree path

Query the current session ([@Entire.md](Entire.md)). If the output is valid JSON, read its `worktree_path` field — that is **the** canonical worktree root for this invocation, set by the backend itself. Use it verbatim in the next step (no `cwd` heuristic needed; symlinks, `/private/var`/`/var` quirks, and subdirectory invocation are all handled).

If the output is not JSON (no active session in this worktree), set the canonical worktree path to `null` and rely on the bidirectional prefix-match fallback in Step 2.

### Step 2: Pick the session

List all sessions as JSON ([@Entire.md](Entire.md)). Each entry has `session_id`, `agent`, `status`, `worktree_path`, `started_at`, `last_active`, `turns`, `last_prompt`, `files_touched`. Apply filters in this order:

1. **Worktree scope.** If you got a canonical worktree path in Step 1, keep entries where `worktree_path` equals it exactly. Otherwise, keep entries where `cwd` starts with `worktree_path` **or** `worktree_path` starts with `cwd`. If either filter yields zero entries, fall back to the unscoped list — better to summarize a slightly-off session than to refuse the handoff.
2. **User-named agent filter** (optional). If the user said "codex", "claude", "kiro", "gemini", etc., keep only entries whose `agent` matches case-insensitively as a substring (so `gemini` matches `Gemini CLI`).
3. **Drop self.** Drop entries where `agent` matches the agent currently running this skill. **If this empties the list**, undo this filter and keep self — the user is asking you to summarize *your own* current session for compaction. Note that fact in the announcement (Step 5).
4. **Pick most recent.** Sort by `last_active` (fall back to `started_at`) descending; take the first.

If filtering still leaves zero entries (truly nothing in the list, even self), print a one-line error (no header) and stop.

### Step 3: Stream the raw transcript

Stream the session transcript to a temp file ([@Entire.md](Entire.md)). The snapshot is bounded to the file size at command start.

### Step 4: Extract conversation content

Extract the original task (head) and final state (tail) from the transcript using the per-agent extraction recipes in [@Entire.md](Entire.md) — transcript formats differ by agent. Do not show the raw extracted lines to the user. They are inputs for Step 5.

### Step 5: Announce, summarize, present

**Announcement.** First line of the body: `Handing off <agent> session — <turns> turns, last active <relative time>, ID <first-8-of-session-id>.` If the picked session is your own (Step 2 self-filter fallback), prepend a one-clause note: `Self-handoff (no other sessions in this worktree)`. This gives the user a chance to catch a wrong pick before reading the summary.

**Summary structure** (skip any section with no genuine content — do **not** hallucinate filler):

1. **Task Overview** — the user's core request, success criteria, stated constraints.
2. **Current State** — completed work: files created/modified, key decisions, artifacts produced.
3. **Important Discoveries** — technical constraints found, rationale behind decisions, errors hit and how they were resolved, failed approaches and why.
4. **Next Steps** — specific remaining actions, blockers, priority ordering.
5. **Context to Preserve** — user preferences, domain details, commitments made during the session.
6. **Unanswered Question** *(only if applicable)* — if the previous agent's last message asked the user a question or presented options that were never answered, capture it exactly as asked.

A one-bug-fix session might legitimately have only Task Overview + Current State + Next Steps. A pure-research session might have only Task Overview + Important Discoveries. Empty sections are a feature; pad them only if you have real content.

**Continue.** Show announcement + summary.

- If section 6 exists, ask the user that question and wait. Do NOT pick a default.
- Otherwise, **immediately pick up the work** — plan, code, or whatever the next step is. Do not ask permission.

## Flow: Checkpoint handoff (user gives a checkpoint ID)

Enumerate the checkpoint's sessions, stream the relevant transcripts, then merge into the same five-section summary — full procedure in [@Entire.md](Entire.md). Treat earlier sessions as the source of "Important Discoveries" and "Context to Preserve"; the latest session feeds "Current State" and "Next Steps". Announce as `Handing off checkpoint <short-id> — <M> sessions, <total turns> turns total.`
