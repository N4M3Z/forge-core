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

| Level | Role |
|-------|------|
| 0 | No access |
| 30 | Developer |
| 40 | Maintainer |
| 60 | Admin |

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

| Operation | Command |
|-----------|---------|
| Protected branches | `glab api projects/:id/protected_branches` |
| Approval rules | `glab api projects/:id/approval_rules` |
| Push rules | `glab api projects/:id/push_rule` |
| Project settings | `glab api projects/:id` |
| Check CODEOWNERS | `glab api projects/:id/repository/files/CODEOWNERS?ref=main` |
