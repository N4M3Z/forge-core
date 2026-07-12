Stage changes (`git add <files>`) but do not commit. The user reviews the staged diff with their preferred tool (`tuicr`, `revdiff`, `git diff --cached`) before the commit lands. Commit only after explicit approval — words like `commit`, `looks good`, `lgtm`, `go`. Pre-commit hooks passing is not approval; they verify correctness, not intent.

For multi-step work, stage incrementally so each step is reviewable on its own rather than as one large diff.

Review approval covers pull requests the same way: merging is a review decision. A PR the user has not reviewed does not merge, even under an approved plan or sequence — plan approval is not merge approval. Merge only on explicit words naming the PRs (`merge them`, `merge #77`).

See [StagedReview](../skills/StagedReview/SKILL.md) for the review workflow.
