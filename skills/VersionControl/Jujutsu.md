# Jujutsu (jj) workflow

When a repo is colocated with jj (`.jj/` at the root), there is no staging area and the commit and push workflow below replaces the git flow. Detect by the presence of `.jj/`; drive mutations through jj and keep raw git read-only. Colocation setup, git-hook-tool coexistence, workspaces, and recovery live in the forge-dev `JujutsuToolkit` skill; commands live in `docs/tldrs/jujutsu.md`; rationale in `docs/decisions/ARCH-0032`.

## The squash workflow

1. `jj describe -m "feat: thing"` names the unit of work.
2. Edit. Every jj command auto-snapshots `@`; there is nothing to stage and nothing is lost.
3. `jj squash` folds `@` into its described parent, or `jj split` carves a too-large `@` into clean changes.
4. `jj bookmark set <name> -r @-`. Bookmarks do NOT auto-advance like git branches; move the bookmark explicitly before pushing or you push the wrong revision.
5. `jj push` (not bare `jj git push`): the `make install`-wired alias runs the pre-push secret gate, then pushes. See below.

After a squash-merged PR, reconcile with `jj git fetch` then `jj rebase -d main@origin --skip-emptied` (drops the now-empty original change).

## Signing is batched at push

jj signs at push, not per commit: `signing.behavior=drop` (no signing on working-copy snapshots, which would touch the YubiKey on nearly every command) plus `git.sign-on-push=true` (sign all pushed commits in one batch). One touch per push, and pushed commits land "Verified" on GitHub. Set by `scripts/configure/jujutsu.sh`. A misconfigured `[signing]` fails silently; confirm with `jj log -T 'signature'` or the GitHub badge.

## Secret gates run at push, automatically

jj runs no git hooks, so the commit-time gates from the parent skill are bypassed (gitleaks fires through `.githooks/pre-commit`; the safety-net hook intercepts `git commit`, which jj never calls). `make install` relocates the gate: it wires a repo-local jj `push` alias to `.githooks/jj-push`, which runs `prek run --all-files --stage pre-push` (gitleaks, semgrep) and only then `jj git push`. So push with **`jj push`**, not `jj git push`; the alias is the gate.

If the alias is not wired (an older repo, or you call `jj git push` directly), scan the outgoing commits by hand first:

```sh
gitleaks git --log-opts "main@origin..@-"
```

CI re-runs the same `--stage pre-push` gate as the backstop. Only the bookmarked change is pushed, so transient mid-sitting secrets never reach the remote. Never weaken this to a post-push fixup; a public push that leaks a secret needs rotation plus history surgery.
