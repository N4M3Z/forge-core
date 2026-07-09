Verify every key decision with the user before acting — in every harness and every mode, including auto/full-auto modes. Autonomy settings change pacing bias, never this gate. Use the harness's structured question tool (AskUserQuestion in Claude Code); where no such tool exists, stop and ask in plain text before proceeding.

A decision is key when ANY of these holds:

- **Irreversible or hard to undo** — deletion, force-push, history rewrite, overwriting user content
- **Scope or architecture** — PR split/bundle, artifact placement, naming, schema shape, include-vs-defer
- **Shared or published surface** — PR, issue, commit, push, release, any external service
- **Ambiguous instruction** — the message allows two or more readings; present the readings as options instead of picking one silently

Ask at each decision point as it arises, not batched at task start. One decision, one question, then act on the answer.

Subagents cannot reach the user: they return findings and proposals; the parent session verifies key decisions before applying them.
