## GitLab Repo Governance

Branch protection, merge approvals, and push rules via `glab` CLI.

### Protected Branches

**Read protection:**

```bash
glab api projects/:id/protected_branches
glab api projects/:id/protected_branches/main
```

**Set protection:**

```bash
glab api projects/:id/protected_branches --method POST \
    -f name=main \
    -f push_access_level=40 \
    -f merge_access_level=40 \
    -f allow_force_push=false
```

### Access Levels

| Level | Role       |
|-------|------------|
| 0     | No access  |
| 30    | Developer  |
| 40    | Maintainer |
| 60    | Admin      |

### Merge Request Approvals

**Read approval rules:**

```bash
glab api projects/:id/approval_rules
glab api projects/:id/merge_requests/:mr_iid/approval_rules
```

**Set project-level approvals:**

```bash
glab api projects/:id/approval_rules --method POST \
    -f name="Default" \
    -f approvals_required=2

glab api projects/:id --method PUT \
    -f merge_requests_author_approval=false \
    -f reset_approvals_on_push=true
```

### Push Rules

```bash
glab api projects/:id/push_rule

glab api projects/:id/push_rule --method PUT \
    -f deny_delete_tag=true \
    -f member_check=true \
    -f commit_message_regex="^(feat|fix|docs|chore|refactor|test):"
```

### CODEOWNERS

Lives in `CODEOWNERS` at repo root, `.gitlab/`, or `docs/`. Requires `code_owner_approval_required: true` on the protected branch to enforce.

```bash
glab api projects/:id/repository/files/CODEOWNERS?ref=main
glab api projects/:id/repository/files/.gitlab%2FCODEOWNERS?ref=main
```

### Quick Reference

| Operation          | Command                                                       |
|--------------------|---------------------------------------------------------------|
| Protected branches | `glab api projects/:id/protected_branches`                    |
| Approval rules     | `glab api projects/:id/approval_rules`                        |
| Push rules         | `glab api projects/:id/push_rule`                             |
| Project settings   | `glab api projects/:id`                                       |
| Check CODEOWNERS   | `glab api projects/:id/repository/files/CODEOWNERS?ref=main`  |

## GitLab MR Operations

Read-only by default. Confirm with the user before merging, approving, or closing.

```sh
glab mr list [--assignee X] [--label Y] [--state opened|merged|closed] [-R group/project]
glab mr view <ID> [-R group/project]
glab mr diff <ID> [--stat] [-R group/project]
glab mr note <ID> -m "comment" [-R group/project]
glab mr approve <ID> [-R group/project]
```

Always pass `-R <group/project>` when targeting a specific repository.

## GitLab Pipeline Operations

```sh
glab ci status [-R group/project]
glab ci view <pipeline_id> [-R group/project]
glab ci list [-R group/project]
```

When a pipeline fails, drill into the failing job with `glab ci view` and extract the relevant error.

## GitLab Issue Operations

```sh
glab issue list [--assignee X] [--label Y] [--state opened|closed] [-R group/project]
glab issue view <ID> [-R group/project]
glab issue note <ID> -m "comment" [-R group/project]
```

## GitLab Releases

GitLab release publishing has two pitfalls. Both have stable workarounds, but neither is intuitive.

### Source archives are auto-attached and cannot be hidden

Every GitLab release ships with auto-generated source archives (`.zip`, `.tar.gz`, `.tar.bz2`, `.tar`) attached automatically ([gitlab-org/gitlab#282486][GLSRC]). This has been an open issue since 2020 with no plan to make it configurable. Users browsing the release page see the source archives at the top, often before the asset you uploaded.

When you publish a release with a real asset (a binary, a packaged tarball, an installer), document the link to that asset explicitly in the README and release notes. Do not assume users will scroll past the source archives to find it.

### Permanent download URL bypasses the release page

GitLab supports a permanent URL for the latest release of any asset:

```
https://<host>/<group>/<project>/-/releases/permalink/latest/downloads/<asset-name>
```

This URL always resolves to the most recent release's asset of that name. It bypasses the release page entirely, sidestepping the source-archive confusion. Use it in:

- README install instructions ("Download the latest release")
- CI scripts that pull the latest binary
- External documentation that links into the release

### Publishing a release with assets

```sh
glab release create v1.0.0 \
    --name "v1.0.0" \
    --notes "Release notes here" \
    --assets-links '[{"name":"repo-claude-v1.0.0.tar.gz","url":"https://uploads.example.com/repo-claude-v1.0.0.tar.gz"}]' \
    -R group/project
```

The asset URL must already be reachable when the release is created -- GitLab does not host attached files inline; it only links to them. Upload to the project's package registry or an external CDN first.

### Listing, inspecting, deleting

```sh
glab release list -R group/project
glab release view v1.0.0 -R group/project
glab release delete v1.0.0 -R group/project
```

Release deletion removes the release entry but does not remove the underlying tag or any external assets. Use `git push origin :refs/tags/v1.0.0` to remove the tag if needed.

## Advanced API queries

For operations not covered by `glab` subcommands, hit the GitLab API directly:

```sh
glab api projects/:id/merge_requests?state=opened
glab api projects/:id/pipelines/:pipeline_id/jobs
```

[GLSRC]: https://gitlab.com/gitlab-org/gitlab/-/issues/282486
