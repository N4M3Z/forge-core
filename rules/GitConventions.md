Conventional Commits: `type: description`. Lowercase, no trailing period, no scope. Types: `feat`, `fix`, `docs`, `chore`, `refactor`, `test`.

Default branch is `main`. Never use `master` — when creating repos, initializing branches, or referencing the default branch in docs and scripts.

Never add `Co-Authored-By` trailers to git commits unless the user explicitly asks to co-author.

Never skip hooks (`--no-verify`) or bypass signing (`--no-gpg-sign`, `-c commit.gpgsign=false`) unless the user has explicitly asked for it. If a hook fails, investigate and fix the underlying issue.

Before pushing to main, squash fix/chore/test commits into their parent `feat:` commit. Git history on main should read as a sequence of features, not a trail of corrections.

Manage the entire PR lifecycle using platform-native CLIs (`gh`, `glab`) — see [PullRequests][PullRequests.md] for body structure, test plans, and feedback retrieval mandates.
