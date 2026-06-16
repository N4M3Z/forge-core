# Entire backend

Command reference for running SessionHandoff against the [Entire CLI](https://docs.entire.io). All commands are local — no login needed.

Required CLI: entire 0.6.2+ (`session list --json`, `session info --transcript`, `session current --json|--transcript`, `checkpoint explain --json|--transcript|--raw-transcript --session-index N`). If a flag is rejected, tell the user to upgrade and stop.

## Active-session flow commands

Step 1 — resolve the canonical worktree:

```bash
entire session current --json
```

Prints `No active session found in this worktree.` (non-JSON) when nothing is active.

Step 2 — list sessions:

```bash
entire session list --json
```

Step 3 — stream the transcript:

```bash
entire session info <session_id> --transcript > /tmp/handoff-<session_id>.jsonl
```

Output is JSONL for most agents and a single JSON document for Gemini CLI.

## Per-agent extraction recipes

**JSONL agents** (Claude Code / Codex / Cursor / Copilot CLI / Factory AI Droid / OpenCode):

```bash
grep -E '"type":"(message|function_call|user|assistant)"' /tmp/handoff-<session_id>.jsonl | cut -c1-2000 | head -20    # original task
grep -E '"type":"(message|function_call|user|assistant)"' /tmp/handoff-<session_id>.jsonl | cut -c1-2000 | tail -100   # final state
```

**Gemini CLI** (single JSON document — no JSONL grep):

```bash
jq 'keys' /tmp/handoff-<session_id>.jsonl
```

The top-level shape varies by Gemini CLI version, but messages live under one of `messages`, `contents`, `history`, or `turns`. Each entry has a `role` (`user`/`model`/`function`/`tool`) and a content payload under one of `parts[].text`, `content`, or `text`. Extract role + text in chronological order:

```bash
# Example — adapt the path based on what `jq 'keys'` showed.
jq -r '.messages[] | "\(.role): \([.parts[]? | .text // ""] | join(" "))"' /tmp/handoff-<session_id>.jsonl | head -20
jq -r '.messages[] | "\(.role): \([.parts[]? | .text // ""] | join(" "))"' /tmp/handoff-<session_id>.jsonl | tail -100
```

If neither shape works, fall back to the Read tool on the JSON file and locate the message array by inspection.

## Checkpoint handoff flow

Step 1 — enumerate sessions behind the checkpoint:

```bash
entire checkpoint explain <checkpoint-id> --json
```

The envelope's `sessions` array lists every session that contributed. Multi-session checkpoints are common (parallel agents, retries, multi-phase work) and earlier sessions often carry the rationale, failed approaches, and user constraints that the latest session takes for granted.

Step 2 — pick which sessions to stream:

- **1 session.** Stream the normalized compact transcript:

```bash
entire checkpoint explain <checkpoint-id> --transcript > /tmp/handoff-ckpt-<checkpoint-id>.jsonl
```

- **2–8 sessions.** Iterate every index 0..N-1. Do **not** rely on the `--transcript` default (latest session only):

```bash
# for N in 0 .. sessions.length-1
entire checkpoint explain <checkpoint-id> --raw-transcript --session-index <N> > /tmp/handoff-ckpt-<checkpoint-id>-<N>.jsonl
```

- **More than 8 sessions.** Sort the `sessions` array by timestamp descending and take the 8 most recent. Note the cap in the announcement: `<M of N> sessions summarized; oldest <M-N> elided as too old to matter.`

`--raw-transcript` keeps the per-agent raw bytes so the same JSONL grep extraction works. Index 0 is the first session chronologically.

Step 3 — run the per-agent extraction (head + tail per file) on each `/tmp/handoff-ckpt-*.jsonl`, then merge into the single five-section summary per the SKILL.md.
