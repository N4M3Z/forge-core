# Dynamic context injection (`!`)

A Claude Code skill can open with **live machine state** instead of stale prose. `` !`<command>` `` lines in the SKILL.md body run when the skill is invoked, and their output replaces the placeholder before Claude sees the content ("Inject dynamic context", a Claude Code extension to the Agent Skills standard).

When authoring a Claude skill, treat this as a first-class step, not an afterthought: **ask what live state would orient the model on load, and inject it.** A skill that opens with the actual situation (the current branch and diff, a tool's auth status, the names of things that exist right now) beats one that only describes how to go find it. Default to injecting unless there is a reason not to.

```markdown
---
name: MySkill
description: ...
allowed-tools: Bash(git status *) Bash(git diff *)
---

# MySkill

Current branch and changes:

!`git status --short 2>/dev/null || echo "(not a git repo)"`
```

Each `` !`<command>` `` runs once, before the rendered SKILL.md is sent to Claude; the output replaces the placeholder inline. Substitution is single-pass: injected output is not re-scanned for further placeholders.

## Hard constraints (verified by running it, not just the docs)

- **SKILL.md body only.** `!` executes only in the SKILL.md body, never in `@`-companion files (those load as plain text). Put every injected command in SKILL.md and keep companions as reference prose.
- **`allowed-tools` is required.** List the Bash scopes the injected commands need in the SKILL.md frontmatter, e.g. `allowed-tools: Bash(pass *) Bash(git *)`. It is a frontmatter field in SKILL.md itself (space-, comma-, or list-separated); there is no sidecar location. (Note: `forge assemble` currently strips it for the Claude provider, forge-cli#69, until fixed, a forge-deployed skill loses the field.)
- **No shell expansions.** The injection rejects any command containing `$(...)`, `${...}`, or backticks with a `Contains expansion` error. Keep injected commands simple and static; a guarded summary that needs command substitution will not run, inject the raw command output instead.
- **No built-in error handling.** A failing command does not degrade gracefully; it breaks or blanks the injection. Self-guard every command so a missing tool, logged-out session, or empty result cannot break skill load:

  ```markdown
  !`pass-cli vault list 2>/dev/null || echo "(proton pass: not logged in)"`
  ```

- **Claude Code only.** `!`, `@`, and `$ARGUMENTS` are Claude Code extensions, not part of the portable Agent Skills standard. In Codex / Gemini / opencode the `!` lines render as inert literal text. Use injection in skills you accept as Claude-first; it degrades to harmless text elsewhere.

## Substitutions available alongside `!`

`$ARGUMENTS`, `$ARGUMENTS[N]`, `$N`, `$name` (named args), and `${CLAUDE_SESSION_ID}` / `${CLAUDE_EFFORT}` / `${CLAUDE_SKILL_DIR}` are substituted in the SKILL.md body the same way.

## What to inject, and what never to

Inject **read-only, fast, structural state** that orients Claude: the current branch, a file listing, a tool's status, the names of things. Never inject:

- **Secret values.** For a credential skill, inject the *map* (entry names, vault list, auth status), never the *territory*. `` !`pass ls` `` is fine (entry names); `` !`pass show <x>` `` is forbidden, it would dump a live secret into the transcript and context.
- **Slow or interactive commands.** Injection blocks skill load; a command that prompts, hangs, or takes seconds makes the skill feel broken.
- **Mutating commands.** Injection should observe, not change state.

The litmus test: if the command's output appearing verbatim in the session transcript would be a problem, do not inject it.
