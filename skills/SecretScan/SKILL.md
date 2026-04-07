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

## Constraints

- Never commit `.env`, credentials, or API keys — even to private repos
- If gitleaks blocks a commit, fix the leak. Don't bypass with `--no-verify`.
- Different gitleaks versions detect different patterns. If local passes but CI fails, check version mismatch.

[GITLEAKS]: https://github.com/gitleaks/gitleaks
