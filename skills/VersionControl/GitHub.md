## GitHub Repo Governance

Branch protection and code ownership via `gh` CLI.

### Rulesets (Preferred)

Rulesets are the modern replacement for legacy branch protection. They support bypass actors, org-level inheritance, and granular enforcement.

**Read rulesets:**

```bash
gh api repos/OWNER/REPO/rulesets
gh api repos/OWNER/REPO/rulesets/RULESET_ID
```

**Create a ruleset:**

```bash
gh api repos/OWNER/REPO/rulesets --method POST --input - <<'EOF'
{
    "name": "main",
    "target": "branch",
    "enforcement": "active",
    "conditions": {
        "ref_name": { "include": ["~DEFAULT_BRANCH"], "exclude": [] }
    },
    "rules": [
        { "type": "deletion" },
        { "type": "non_fast_forward" },
        {
            "type": "pull_request",
            "parameters": {
                "required_approving_review_count": 1,
                "require_code_owner_review": true,
                "dismiss_stale_reviews_on_push": false,
                "require_last_push_approval": false,
                "required_review_thread_resolution": false,
                "allowed_merge_methods": ["merge", "squash", "rebase"]
            }
        }
    ],
    "bypass_actors": [
        { "actor_id": 5, "actor_type": "RepositoryRole", "bypass_mode": "always" }
    ]
}
EOF
```

**Update / delete:**

```bash
gh api repos/OWNER/REPO/rulesets/RULESET_ID -X PUT --input - <<'EOF'
{ ... }
EOF

gh api repos/OWNER/REPO/rulesets/RULESET_ID --method DELETE
```

### Bypass Actors

| `actor_type`          | `actor_id` values                               | Notes                                    |
|-----------------------|--------------------------------------------------|------------------------------------------|
| `RepositoryRole`      | 1=Read, 2=Triage, 3=Write, 4=Maintain, 5=Admin   | Most common                              |
| `OrganizationAdmin`   | 0                                                 | Org-wide admin bypass                    |
| `Team`                | Team database ID                                  | Find via `gh api orgs/ORG/teams/SLUG`    |

`User` is **not** a valid actor type — use `RepositoryRole` instead.

### Legacy Branch Protection

Still works but rulesets are preferred. The legacy endpoint returns 404 when only rulesets are configured — check rulesets first.

```bash
gh api repos/OWNER/REPO/branches/main/protection

gh api repos/OWNER/REPO/branches/main/protection \
    --method PUT --input - <<'EOF'
{
    "required_status_checks": { "strict": true, "contexts": ["ci/build"] },
    "enforce_admins": false,
    "required_pull_request_reviews": { "required_approving_review_count": 1 },
    "restrictions": null
}
EOF

gh api repos/OWNER/REPO/branches/main/protection --method DELETE
```

### CODEOWNERS

Lives in `.github/CODEOWNERS` (preferred), repo root, or `docs/`. Requires `require_code_owner_review: true` in a ruleset or legacy protection to enforce.

```
# Default owner for everything
* @OWNER

# Per-directory ownership
/src/payments/ @payments-team
/lib/           @OWNER
```

### Quick Reference

| Operation           | Command                                                  |
|---------------------|----------------------------------------------------------|
| List rulesets       | `gh api repos/OWNER/REPO/rulesets`                       |
| View ruleset        | `gh api repos/OWNER/REPO/rulesets/ID`                    |
| Legacy protection   | `gh api repos/OWNER/REPO/branches/BRANCH/protection`     |
| Check CODEOWNERS    | `gh api repos/OWNER/REPO/contents/.github/CODEOWNERS`    |
| Repo settings       | `gh repo edit OWNER/REPO --enable-squash-merge`          |
