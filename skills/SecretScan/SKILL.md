---
name: SecretScan
description: "Commit-time secret scanning with gitleaks — prevent credentials from entering git history. USE WHEN scanning for leaked secrets, setting up pre-commit hooks, or auditing repositories for credentials."
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
gitleaks detect --source . --no-git
```

### Scan git history

```sh
gitleaks detect --source .
```

### Scan staged files only

For pre-commit checks where only staged content matters:

```sh
gitleaks protect --source . --staged --no-banner
```

`gitleaks protect` (vs `detect`) operates on the working-tree diff and is faster than a full scan when integrated into a pre-commit flow.

### Baseline known findings

If the repo has historical secrets that have been rotated, create a baseline so future scans only flag new leaks:

```sh
gitleaks detect --source . --report-path .gitleaks-baseline.json
gitleaks detect --source . --baseline-path .gitleaks-baseline.json
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

## .gitleaks.toml

Config file at the project root for allowlists. Use path exclusions, not fingerprints — fingerprints break when line numbers shift:

```toml
[allowlist]
paths = [
    "evals/baselines/.*",
    "tests/fixtures/.*",
]
```

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
- If gitleaks blocks a commit, fix the leak; do not bypass with `--no-verify`
- Recommend baselining over `--no-verify` for historical secrets that have already been rotated
- Flag any `.env` file that is not in `.gitignore` as a configuration issue
- Different gitleaks versions detect different patterns; if local passes but CI fails, check version mismatch

[GITLEAKS]: https://github.com/gitleaks/gitleaks
