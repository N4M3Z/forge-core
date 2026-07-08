Parallel-work isolation routes by the repo's VCS. Agents work in jj changes wherever jj is available; git commits and branches are the human-boundary artifact (push, PR, review).

In a jj-colocated repo (`.jj/` at root): never use git worktrees or `isolation: "worktree"` agent spawns. `git worktree add` mutates refs behind jj's back, and jj's auto-snapshot does not cover trees it doesn't own. Use one `jj workspace add ../repo-<name>` per parallel agent (shared store and op-log, isolated working copy); clean up with `jj workspace forget`. Mechanics in the JujutsuToolkit skill; commit and push discipline in VersionControl/Jujutsu.md.

In a git-only repo, use git worktrees for parallel feature work instead of stashing or switching branches:

```sh
git worktree add .worktrees/feature-branch feature-branch
git worktree remove .worktrees/feature-branch
git worktree list
```

Worktrees live in `.worktrees/<branch-name>` inside the repo, ignored by `.gitignore` (add the entry before creating the first worktree). The sibling-directory pattern (`../repo-branchname`) also works but pollutes the parent directory and breaks paths in IDE workspaces.

When spawning agents for parallel implementation in git-only repos, use `isolation: "worktree"` so each agent works on an isolated copy.
