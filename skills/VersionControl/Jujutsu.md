# Jujutsu (jj) workflow

When a repo is colocated with jj (`.jj/` at the root), there is no staging area and the commit and push workflow below replaces the git flow. Detect by the presence of `.jj/`; drive mutations through jj and keep raw git read-only. Colocation setup, git-hook-tool coexistence, workspaces, and recovery live in the forge-dev `JujutsuToolkit` skill; commands live in `docs/tldrs/jujutsu.md`; rationale in `docs/decisions/ARCH-0032`.

## The squash workflow

1. `jj describe -m "feat: thing"` names the unit of work.
2. Edit. Every jj command auto-snapshots `@`; there is nothing to stage and nothing is lost.
3. `jj squash` folds `@` into its described parent, or `jj split` carves a too-large `@` into clean changes.
4. `jj bookmark set <name> -r @-`. Bookmarks do NOT auto-advance like git branches; move the bookmark explicitly before pushing or you push the wrong revision. Bookmark only a *described* change: an undescribed `@` pushed as-is lands in git history as an empty-message commit (unsigned too, if it predates sign-on-push).
5. `jj push` (not bare `jj git push`): the `make install`-wired alias runs the pre-push secret gate, then pushes. See below.

After a squash-merged PR, reconcile with `jj git fetch` then `jj rebase -d main@origin --skip-emptied` (drops the now-empty original change).

## Auto-snapshot pulls in out-of-band drift

Auto-snapshot has a downside: jj snapshots every non-gitignored file into `@`, so a tool that writes into the tree out-of-band (Entire reinstalling its `.githooks/*` session hooks, a generator dropping output) silently lands those files in whatever commit `@` is — including a feature commit about to be pushed. Gitignore the tool's local files so jj never tracks them, or park `@` on a throwaway scratch commit (`jj new -m scratch`) so drift accumulates there. To pull drift back out of a commit it already polluted, reach for `jj squash --from <commit> --into <scratch> <paths>` or `jj duplicate <rev> -d <dest>` — not `jj restore`, whose name the `git restore` safety gate pattern-matches and blocks even though jj restore is op-log-reversible.

## Signing is batched at push

jj signs at push, not per commit: `signing.behavior=drop` (no signing on working-copy snapshots, which would touch the YubiKey on nearly every command) plus `git.sign-on-push=true` (sign all pushed commits in one batch). One touch per push, and pushed commits land "Verified" on GitHub. Set by `scripts/configure/jujutsu.sh`. A misconfigured `[signing]` fails silently; confirm with `jj log -T 'signature'` or the GitHub badge.

A locally-unsigned jj commit is therefore expected, not a defect. Do NOT "fix" it by bypassing jj (a raw `git commit -S`, a re-sign, or tearing the change down): no per-commit signing prompt and a blank `jj log -T 'signature'` are the batched model working, signatures land at push. When a user asks why no signing prompt fired, explain batched-at-push rather than rebuilding the commit through git. The one real misconfiguration is `drop` *without* `git.sign-on-push=true` — only then do commits never sign, and the fix is to set sign-on-push, not to abandon jj. Check both keys (`jj config get signing.behavior` and `jj config get git.sign-on-push`) before concluding signing is broken.

## Secret gates run at push, automatically

jj runs no git hooks, so the commit-time gates from the parent skill are bypassed (gitleaks fires through `.githooks/pre-commit`; the safety-net hook intercepts `git commit`, which jj never calls). `make install` relocates the gate: it wires a repo-local jj `push` alias to `.githooks/jj-push`, which runs `prek run --all-files --stage pre-push` (gitleaks, semgrep) and only then `jj git push`. So push with **`jj push`**, not `jj git push`; the alias is the gate.

If the alias is not wired (an older repo, or you call `jj git push` directly), scan the outgoing commits by hand first:

```sh
gitleaks git --log-opts "main@origin..@-"
```

CI re-runs the same `--stage pre-push` gate as the backstop. Only the bookmarked change is pushed, so transient mid-sitting secrets never reach the remote. Never weaken this to a post-push fixup; a public push that leaks a secret needs rotation plus history surgery.

## Parallel work uses workspaces, not git worktrees

In a colocated repo, `git worktree add` mutates refs behind jj's back — the GitWorktrees skill, EnterWorktree, and worktree-isolated subagents are all off-limits (a settings hook blocks EnterWorktree). The replacement: `jj workspace add ../repo-<name>`, one workspace per agent, based on a stable commit (`trunk()` or a described change), never another session's live `@`. "Working copy is stale" is routine — `jj workspace update-stale` re-syncs. Finish with `jj workspace forget <name>` (the directory stays; remove it separately). Full mechanics in the forge-dev JujutsuToolkit skill.

## A change description is text, not a scratchpad

A jj change description holds arbitrary text, and because the repo is git-colocated a described change IS a reviewable git commit. That makes a throwaway change a lightweight relay envelope: `jj new -m "<brief>"`, hand it to a reviewing harness, then `jj abandon` it after (file-free, gone as long as it is not pushed). But a real commit's message stays what-changed-and-why (GitConventions); never stuff a review brief into the commit that carries the change. The brief belongs on its own throwaway change or a tracked prompt file.
