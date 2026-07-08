---
name: ExecutePlan
version: 0.2.0
description: "Execute an implementation plan inline — task by task in a single session — then finish the work: verify, present integration options (merge, PR, keep, discard), and clean up the workspace. USE WHEN executing plan, run plan, implement plan, inline execution, implementation complete, deciding merge strategy, finishing a feature branch or workspace."
---

# ExecutePlan

Execute a WritePlan output in the current session, one task at a time, then land the result. This is the sequential alternative to DeveloperSprint (parallel agents). Use ExecutePlan for smaller plans or when tasks have sequential dependencies.

1. **Load the plan** — read the plan file from `docs/plans/`
2. **Critical review** — before starting, check: are tasks ordered correctly? Are dependencies satisfied? Any gaps? If issues found, fix the plan first or ask the user.
3. **Set up workspace** — if the plan modifies existing code, isolate by VCS: a jj workspace (`jj workspace add ../repo-<name>`) in jj-colocated repos, a git worktree in git-only repos. Run project setup and the test suite once for a clean baseline; stop on a broken baseline.
4. **Execute task by task**:
    - Read the task specification
    - Implement exactly what the task says
    - Run the verification step specified in the task
    - Invoke VerifyCompletion before marking the task done
    - Move to the next task only after the current one passes
5. **Handle blockers** — if stuck, stop and ask the user. Never guess past a blocker.
6. **Final verification** — after all tasks, run the full build + test suite. If tests fail, fix before offering integration; never merge or PR a red tree.
7. **Finish** — present exactly these options and execute the choice:
    1. Merge back to the base branch locally
    2. Push and create a Pull Request
    3. Keep as-is (user handles it later)
    4. Discard this work
8. **Report** — summarize what was done, what was skipped, what needs follow-up

## Finishing mechanics

Git-only repos:

- **Merge locally:** `git switch <base>` → `git pull` → `git merge <feature>` → re-run tests on the result → `git branch -d <feature>`
- **PR:** `git push -u origin <feature>` → `gh pr create` (or `glab`) with Summary + Test plan body
- **Discard:** requires the user to type `discard` — it deletes the branch, its commits, and the worktree. Then `git switch <base>` → `git branch -D <feature>`
- **Cleanup (merge and discard; PR keeps the tree until merged):** leave the worktree (`cd` to the main checkout), `git worktree remove <path>`, then sweep orphans: any linked worktree in `git worktree list` whose tree is clean and whose HEAD is already an ancestor of mainline gets removed. Session-scoped worktrees sit at detached HEAD under `~/worktrees/<repo>/<name>/`, invisible to branch-based checks.

jj-colocated repos (no branches to finish, no worktrees to remove):

- **Land:** `jj bookmark set <name> -r @-` on the described change, then `jj push` (the gated alias)
- **Discard:** `jj abandon` the change (op-log-reversible, no typed confirmation needed)
- **Cleanup:** `jj workspace forget <name>` for any workspaces created in step 3; the directory is removed separately

## Red Flags

| Thought                                           | Reality                                                      |
| ------------------------------------------------- | ------------------------------------------------------------ |
| "I'll do tasks 3 and 4 together, they're related" | One task at a time. Verify each before moving on.            |
| "This task is wrong, let me improvise"            | Stop. Fix the plan or ask the user. Don't freelance.         |
| "I can skip verification on this one"             | No. VerifyCompletion on every task.                          |
| "I'm blocked but I can probably work around it"   | Stop and ask. Workarounds create hidden dependencies.        |
| "Let me also fix this while I'm here"             | Scope creep. Do what the plan says, nothing more.            |
| "The plan is mostly done, close enough"           | Partially executed plans are worse than unstarted ones.      |
| "Tests are red but the merge is small"            | Never merge or PR a red tree. Fix first.                     |
| "I'll clean up the worktree later"                | A merge is not complete while its worktree still exists.     |

## Constraints

- One task at a time — never batch or skip ahead
- Verify each task before proceeding to the next
- Stop on blockers — ask the user, don't guess
- No scope expansion beyond the plan
- Isolate by VCS: jj workspace in jj-colocated repos, git worktree in git-only repos
- Present exactly the four finish options; typed `discard` confirmation before destroying git work
- For plans with independent tracks, use DeveloperSprint instead

## Sources

- <https://github.com/obra/superpowers>
- <https://github.com/davila7/claude-code-templates>
