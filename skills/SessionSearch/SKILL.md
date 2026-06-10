---
name: SessionSearch
version: 0.1.0
description: "Search past agent sessions and checkpoints — semantic + keyword recall across repos, branches, authors, and time windows. USE WHEN have we done this before, search past work, find the previous implementation, look for checkpoints about X, recover a prior prompt. Not for the current active session — use SessionHandoff for that."
allowed-tools: Bash
upstream: https://github.com/entireio/skills/blob/main/skills/search/SKILL.md
---

# SessionSearch

Search captured agent sessions before guessing from memory. The checkpoint store is the long-term memory of every captured session; query it first when the user suspects prior art. Backend commands live in [@Entire.md](Entire.md).

## Response Format

Begin the first response to this skill invocation with the line:

`Entire Search:`

followed by a blank line, then the content.

- Apply the header to the **first response of the invocation only.** Do not re-print it on follow-up turns within the same invocation (e.g. after the user answers a clarifying question).
- Do **not** include the header on error or early-exit responses (e.g. "CLI not installed", "authentication required", "no matches"). The header's presence should signal that the skill ran and produced real output.

## When to Use

- The user asks things like "have we done this before?", "search past work", "find the previous implementation", or "look for checkpoints about X"
- You need prior context from another branch, repo, author, or recent time period
- You want likely matches first, then a deeper transcript read only for the best hit

Do not use this for the current active session. Use SessionHandoff for that.

## Process

1. Run a focused search with JSON output so results are easy to inspect — primary command and filter syntax in [@Entire.md](Entire.md). Add filters when the user already gave them or when the first search is too broad.
2. Review the top matches and summarize the likely candidates for the user. Do not dump raw JSON unless they ask for it.
3. If the user wants details on a specific result, deep-read that checkpoint's transcript (commands in [@Entire.md](Entire.md)).

## Search Heuristics

- Start with the user's domain terms, feature name, error text, file name, or ticket ID
- Prefer narrower searches before increasing the result limit
- Scope the repository explicitly when it matters (single repo or all repos)
- If there are no useful hits, broaden in this order: remove branch filter, widen date, simplify query terms

## Failure Modes

- If search says authentication is required, tell the user to log in (see [@Entire.md](Entire.md))
- If there are no matches, say that clearly and mention the filters or query terms you tried
- If the user really wants the current session, switch to SessionHandoff instead of searching checkpoints
