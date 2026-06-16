---
name: SessionExplain
version: 0.1.0
description: "Explain the intent behind source code by tracing it to the agent session transcript that created it. USE WHEN why does this function exist, what is this file for, why was this line added, explain this code's history, trace code to its originating conversation."
allowed-tools: Bash, Task
upstream: https://github.com/entireio/skills/blob/main/skills/explain/SKILL.md
---

# SessionExplain

Explain the intent behind source code by tracing it back to the original conversation where it was created. Backend commands live in [@Entire.md](Entire.md). Works with:

- **Functions** — Why does this function exist? What problem was it solving?
- **Files** — What's the purpose of this file? What requirements drove its creation?
- **Line changes** — Why was this specific line added or modified?

## Response Format

Begin the first response to this skill invocation with the line:

`Entire Explain:`

followed by a blank line, then the content.

- Apply the header to the **first response of the invocation only.** Do not re-print it on follow-up turns within the same invocation (e.g. after the user answers a clarifying question).
- Do **not** include the header on error or early-exit responses (e.g. "CLI is required but not installed", "this file is not tracked by git", "no session transcript was found for this commit"). The header's presence should signal that the skill ran and produced real output.

## Process

1. Verify the backend CLI is installed (see [@Entire.md](Entire.md)).
   - If it is not, stop and tell the user how to install it.
2. Use a fast subagent to identify the commit that introduced the code via git blame or git log.
   - If the file is not tracked by git, stop and tell the user: "This file is not tracked by git, so I can't trace its history."
   - If git blame returns no useful result (e.g., the code is uncommitted), stop and tell the user: "This code hasn't been committed yet, so there's no history to trace."
3. Use a subagent to read the session transcript for that commit (command in [@Entire.md](Entire.md)).
   - If the command fails or returns no transcript, stop and tell the user: "No session transcript was found for this commit. It may have been created outside of a captured session (e.g., a manual commit)."
