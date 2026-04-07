Use `.gitleaks.toml` for path exclusions instead of `.gitleaksignore` fingerprints. Fingerprints break when line numbers shift. Path exclusions are stable:

```toml
[allowlist]
paths = [
    "evals/baselines/.*",
]
```

Different gitleaks versions (apt vs homebrew vs GitHub Action) detect different patterns. If local scans pass but CI fails, the version mismatch is the likely cause.
