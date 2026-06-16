# Entire backend

Command reference for running SessionExplain against the [Entire CLI](https://docs.entire.io). Explain works locally — no login needed.

## Verify the CLI

```bash
entire version
```

If the command is not found: `brew tap entireio/tap && brew install --cask entire` (docs: <https://docs.entire.io/cli/installation>).

## Read the transcript for a commit

```bash
entire explain --no-pager --commit <COMMIT_SHA>
```

Verbosity ladder when more or less detail is needed:

- `--short` — condensed summary
- (default) — parsed transcript view
- `--full` — complete parsed transcript
- `--raw-transcript` — raw bytes, last resort

Older CLI builds expose this as `entire checkpoint explain`; if the bare verb is rejected, retry the namespaced form.

## Preconditions

- The repo must have Entire enabled at the time the commit was made (`entire status` to check; checkpoints live on per-session `entire/<hash>` branches)
- Commits made outside a captured session (manual commits) have no transcript — expected, not an error
