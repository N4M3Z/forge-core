---
name: SecretScan
description: "Commit-time secret scanning with gitleaks — prevent credentials from entering git history. USE WHEN scanning for leaked secrets, setting up pre-commit hooks, auditing repositories for credentials, configuring gitleaks allowlists, or encrypting user-specific module data with git-crypt."
version: 0.1.0
---

# SecretScan

Prevent secrets from entering git history using [gitleaks][GITLEAKS].

## Setup

### Install

```sh
brew install gitleaks
```

### Scan the working tree

```sh
gitleaks dir .
```

### Scan git history

```sh
gitleaks git .
```

### Scan staged files only

For pre-commit checks where only staged content matters:

```sh
gitleaks git --staged . --no-banner
```

### Baseline known findings

If the repo has historical secrets that have been rotated, create a baseline so future scans only flag new leaks:

```sh
gitleaks git . --report-path .gitleaks-baseline.json
gitleaks git . --baseline-path .gitleaks-baseline.json
```

## Pre-commit hook

Add to `.pre-commit-config.yaml`:

```yaml
- id: gitleaks
  name: gitleaks
  entry: gitleaks detect --no-banner --no-git -s .
  language: system
  pass_filenames: false
```

## Configuration

Use `.gitleaks.toml` for path exclusions instead of `.gitleaksignore` fingerprints. Fingerprints break when line numbers shift; path exclusions are stable:

```toml
[allowlist]
paths = [
    "evals/baselines/.*",
]
```

Different gitleaks versions (apt vs homebrew vs GitHub Action) detect different patterns. If local scans pass but CI fails, the version mismatch is the likely cause.

## Encrypt user-specific data

Modules with user-specific data (credentials, personal identifiers, insurance numbers) use git-crypt to encrypt those files in the public repo. Files are plaintext locally, encrypted blobs on push.

```sh
brew install git-crypt
cd module-root
git-crypt init
git-crypt add-gpg-user YOUR_GPG_KEY_ID
```

Add a `.gitattributes` entry for the encrypted path:

```
rules/user/** filter=git-crypt diff=git-crypt
```

Remove `rules/user/` from `.gitignore` after git-crypt is configured; the files are then safe to commit. The `rules/user/` directory holds per-user data that the module's skills need at runtime (insurance identifiers, API account slugs, tax office codes) but must not be readable in the public repo. Until git-crypt is configured, `rules/user/` stays gitignored as a fallback.

## Output format

Present findings grouped by severity, never echoing the secret value:

```markdown
## Secret Scan: <repo>

**Mode**: working tree | staged | history
**Findings**: <count>

### Critical (must fix before merge)
- <file>:<line> <rule-id> — short description

### Allowlisted (known safe)
- <file>:<line> <rule-id> — reason

### Recommendation
<fix | baseline | allowlist guidance>
```

## Constraints

- Never display the actual secret value in scan output — show only rule ID, file, and line
- Never commit `.env`, credentials, or API keys — even to private repos
- If gitleaks is not installed, print the install command (`brew install gitleaks`) and stop — do not partially scan
- Recommend baselining over `--no-verify` for historical secrets that have already been rotated
- Flag any `.env` file that is not in `.gitignore` as a configuration issue

[GITLEAKS]: https://github.com/gitleaks/gitleaks
