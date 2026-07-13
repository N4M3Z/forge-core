PR titles and commit messages describe what changed, not why it was discovered. The change stands on its own.

Every PR or issue reference in output the user reads — chat replies, reports, review handoffs, docs — carries its full bare URL (`https://github.com/owner/repo/pull/67`), never a naked `#67` and never markdown-wrapped `[#67](url)`: terminal views render only bare URLs as clickable. The bare number alone is fine only where the platform auto-links it (PR bodies, commit messages, GitHub comments).

### Body Structure

The first line is a one-sentence summary in prose, no heading. Then exactly three sections:

1. **## Plan** — the design rationale in brief prose: why this shape and not the alternative. Never paraphrase the diff.
2. **## Changes** — file-first bullets: bold artifact name plus backticked path, colon, then what it changes. Dense and specific, one bullet per artifact or concern.
3. **## Testing** — markdown task list: `- [x]` completed, `- [ ]` pending. Cite the commands run.

Link the closing issue with `Closes #NN` right after the summary line.

The canonical machine-checkable form is `pull-request.mdschema`, shipped with the PullRequest skill; validate the drafted body with `mdschema check` before creating the PR.

### Platform Tooling

When a repository is managed by a supported platform (GitHub, GitLab), you MUST use the respective CLI (`gh`, `glab`) for the entire lifecycle.

- **Feedback First**: If told there is feedback, immediately use `gh pr view --comments` or `gh pr view --web` before asking for clarification.
- **Discovery**: Check `gh pr list` or `gh issue list` to avoid duplicating existing work.
- **Operations**: Use CLI tools for PR creation (`--fill`), status checks, and merging.

### Stacked PRs

When a feature branch targets another feature branch as its base, the child PR's content does not cascade to main when the parent PR merges. Squash-merging PR A (`feature-A` → `main`) creates a new commit on main with A's content but leaves `origin/feature-A` as a divergent branch. PR B (`feature-B` → `feature-A`) then merges into the divergent `feature-A`, not main.

Retarget PR B to main after PR A merges, or it will appear "merged" on GitHub while its content never reaches main.
