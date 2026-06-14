---
name: StagedReview
description: "Review your own staged changes via a code-review TUI before triggering a commit. USE WHEN about to commit, walking through your own staged diff, self-reviewing before approval, tuicr, revdiff, git diff cached."
version: 0.1.0
allowed-tools: Bash, Read
---

# StagedReview

After staging changes with `git add`, walk the diff before committing. Annotate friction points, fix them, restage, re-review.

This skill is paired with the [StageForReview][SFR] rule: agents stage but do not commit; the user reviews the staged set and signals approval; then the commit runs.

## Tools

| Tool                | Strength                                                  | Worktree compatibility |
|---------------------|-----------------------------------------------------------|------------------------|
| `tuicr`             | TUI with vim keybindings, GitHub-style annotation export | Limited (see caveat)   |
| `revdiff`           | TUI with `--staged` flag, in-place annotations           | Limited (see caveat)   |
| `git diff --cached` | Plain text, universal, no install                         | Full                   |

`tuicr` and `revdiff` are equivalent in role; pick by personal preference. `git diff --cached` is the always-available baseline.

## Flow

1. **Stage**: `git add <files>` by name. Never `-A` or `.`.
2. **Open the diff for review.** When both `tuicr` and `cmux` are present, open it automatically in a side pane (the CmuxToolkit skill) so review sits beside the work, rather than telling the user to run a command:
    ```sh
    surf=$(cmux new-split right --focus true | grep -oE 'surface:[0-9]+')
    cmux send --surface "$surf" "tuicr -w\n"                         # staged / working tree
    # jj-colocated repo: send tuicr -r 'main@origin..<bookmark>' for the outgoing change instead
    ```
    Otherwise (no cmux, or no tuicr) run a reviewer in the current pane:
    ```sh
    revdiff --staged                   # purpose-built for the staged set
    tuicr -w                            # working-tree mode; see `tuicr --help` for revset combos
    git diff --cached                   # plain text fallback
    ```
3. **Annotate** issues in the TUI; export to clipboard or stdout if the tool supports it.
4. **Fix** issues by editing the affected files. Re-`git add` them.
5. **Re-review** until clean.
6. **Approve and commit**. The agent commits only after the user signals approval.

## Worktree caveat

In a git worktree (`.worktrees/<branch>` per [GitWorktrees](../VersionControl/GitWorktrees.md)), the `.git` entry is a file pointing to the parent's `.git/worktrees/<branch>` directory. `tuicr` and `revdiff` can fail to walk this indirection cleanly.

Workarounds:

- **Fall back to `git diff --cached`** in the worktree. Universal and works.
- **Switch the main checkout to the branch** under review: `git worktree remove .worktrees/<branch>` then `git switch <branch>` in the main checkout. Run the TUI from the main checkout, which has a real `.git` directory.
- **Run with explicit git paths**: `GIT_DIR=$(git rev-parse --git-dir) GIT_WORK_TREE=$(git rev-parse --show-toplevel) tuicr ...`. Hit-or-miss depending on the tool's internals.

Until upstream support lands, the main-checkout path is the cleanest for non-trivial diffs.

## What to look for during self-review

- Unintended files staged (config dumps, build artifacts, secrets)
- Comments left as TODO or scratch notes
- Inconsistent naming across the diff
- Tests that don't actually assert content (`assert!(result.is_ok())` without checking the value — see [TestCorrectness](../../rules/TestCorrectness.md))
- Inline duplication of logic that already exists elsewhere ([AvoidDuplication](../../rules/AvoidDuplication.md))
- Em dashes ([NoEmDash](../../rules/NoEmDash.md))

[SFR]: ../../rules/StageForReview.md
