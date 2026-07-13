Conventional Commits: `type: description`. Lowercase, no trailing period, no scope. Types: `feat`, `fix`, `docs`, `chore`, `refactor`, `test`.

Default branch is `main`. Never use `master` — when creating repos, initializing branches, or referencing the default branch in docs and scripts.

AI agents commit under their own author identity so anyone reading history knows who wrote what: author name carries the agent and its model id (`Claude Fable 5 (claude-fable-5)`), author email the agent's address at the user's domain. Signing stays with the user's key. When several contributors produce one commit — agents from different vendors, a reviewing human — the primary author takes the git author field and every other contributor gets a `Co-Authored-By` trailer with the same identity format. A solo commit carries no trailers; the author field alone answers who wrote it.

The agent identity comes from the harness env (`JJ_USER`/`JJ_EMAIL`, `GIT_AUTHOR_NAME`/`GIT_AUTHOR_EMAIL` in the harness settings), never from per-repo VCS config, which would misattribute the user's own commits. GitHub squash merges rewrite the author to the PR author but append the co-author trailer automatically when the branch author differs.

Never skip hooks (`--no-verify`) or bypass signing (`--no-gpg-sign`, `-c commit.gpgsign=false`) unless the user has explicitly asked for it. If a hook fails, investigate and fix the underlying issue.

Before pushing to main, squash fix/chore/test commits into their parent `feat:` commit. Git history on main should read as a sequence of features, not a trail of corrections.

Manage the entire PR lifecycle using platform-native CLIs (`gh`, `glab`) — see [PullRequests][PullRequests.md] for body structure, test plans, and feedback retrieval mandates.
