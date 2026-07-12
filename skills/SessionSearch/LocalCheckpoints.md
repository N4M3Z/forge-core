# Local Checkpoints

Reading and backfilling Entire checkpoints straight from local git refs. Works offline with no login, and is the only path when `strategy_options.push_sessions` is false (sessions never leave the machine).

## Layout

| Layer | Location | Contents |
| --- | --- | --- |
| Shadow refs (uncommitted work) | branch `entire/<base-sha7>-<worktree6>` | one commit per checkpoint; subject is the user prompt; trailers `Entire-Session`, `Entire-Metadata`; tree holds `.entire/metadata/<session-id>/{full.jsonl,prompt.txt,tasks/}` |
| Committed checkpoints | branch `entire/checkpoints/v1`, sharded `<id[:2]>/<id[2:]>/` | root `metadata.json` (sessions, files_touched, token_usage) plus per-session `full.jsonl`, `prompt.txt`, `content_hash.txt` |
| Session state | `.git/entire-sessions/<uuid>.json` + `.agent`, `.model` sidecars | base_commit (locates the shadow ref), checkpoint_count, token_usage, agent and model labels |
| Commit linkage | trailer `Entire-Checkpoint: <12-hex>` in the commit message | survives amend and rebase |

## Reading

```bash
git for-each-ref 'refs/heads/entire/*' --format='%(refname:short) %(objectname:short)'
git log <shadow-ref> --format='%h%x00%ct%x00%s%x00%(trailers:key=Entire-Session,valueonly)'
git ls-tree -d --name-only '<shadow-ref>:.entire/metadata'
git show '<shadow-ref>:.entire/metadata/<session-id>/prompt.txt'
git show 'entire/checkpoints/v1:<id[:2]>/<id[2:]>/metadata.json'
```

Multiple sessions interleave on one shadow ref — filter by the `Entire-Session` trailer, never assume one session per ref. `full.jsonl` transcripts run 5–46 MB; filter, never dump.

## Backfilling history (`entire session attach <session-id>`)

Builds a checkpoint from a transcript that hooks never captured (reads the agent's own session file, e.g. `~/.claude/projects/<project>/<id>.jsonl`). Links to HEAD only — there is no past-commit form.

- The trailer amend is message-only (`git commit --amend --only`); a staged index is never absorbed.
- Once HEAD carries an `Entire-Checkpoint` trailer, further attaches append their sessions to the same checkpoint with no amend — attach the first session right after a commit; the rest join for free.
- Agent `-m` commits can miss the trailer on a session's first condensation. Verify after committing: `git log -1 --format='%B' | grep Entire-Checkpoint` — add it via rebase reword if absent.
