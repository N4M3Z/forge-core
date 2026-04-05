---
title: "Verified Remote Execution"
description: "Remote scripts in CI and hooks must be hash-verified before execution"
type: adr
category: security
tags:
    - security
    - ci
    - supply-chain
status: accepted
created: 2026-04-02
updated: 2026-04-02
author: "@N4M3Z"
project: forge-core
related: ["CORE-0010 Unified Module Validation.md"]
responsible: ["@N4M3Z"]
accountable: ["@N4M3Z"]
consulted: []
informed: []
upstream: []
---

# Verified Remote Execution

## Context and Problem Statement

CI pipelines and pre-commit hooks sometimes fetch scripts from the network. Blind `curl | bash` trusts the remote server at every run — a compromised upstream silently changes what executes. However, remote execution itself is not the problem. Fetching a script and running it is fine if the content is verified against a known-good hash before execution.

## Decision Drivers

- Remote scripts are convenient — always current, zero local maintenance
- The risk is unverified execution, not remote fetching
- A committed hash acts as a trust anchor — the script can change, but execution requires explicit hash update
- Supply chain attacks target the gap between "fetched" and "verified" ([SLSA threat model][SLSA-THREATS])

## Considered Options

1. **Blind curl | bash** — no verification, full trust in upstream
2. **No remote execution** — only committed local copies, manual updates
3. **Hash-verified remote execution** — fetch the script, verify its SHA-256 against a committed hash, execute only if it matches

## Decision Outcome

Chosen option: **hash-verified remote execution**, because it allows remote convenience while maintaining a cryptographic trust boundary.

**The rule:** remote scripts fetched in CI or pre-commit hooks must be verified against a SHA-256 hash committed to the repository before execution. If the hash does not match, the pipeline must fail or fall back to a committed local copy.

```sh
EXPECTED_HASH="abc123..."
SCRIPT=$(curl -sfL https://raw.githubusercontent.com/N4M3Z/forge-cli/main/bin/validate.sh)
ACTUAL_HASH=$(echo "$SCRIPT" | shasum -a 256 | cut -d' ' -f1)

if [ "$ACTUAL_HASH" != "$EXPECTED_HASH" ]; then
    echo "warning: upstream validate.sh hash mismatch, using local copy"
    bash bin/validate.sh
else
    echo "$SCRIPT" | bash
fi
```

**Updating the hash** is an explicit action: review the upstream changes, update the committed hash, push. Every change to the executed code passes through the repository's review process.

**Local copy fallback** ensures the pipeline never fails silently when the remote is unavailable or the hash mismatches.

### Consequences

- [+] Remote scripts execute only when their content matches the committed hash
- [+] Compromised upstream is detected immediately — hash mismatch blocks execution
- [+] Fallback to local copy means CI never breaks due to network issues
- [+] Consistent with SLSA build integrity requirements ([SLSA L2][SLSA-LEVELS])
- [-] Hash must be updated manually when adopting upstream changes (intentional friction)

## Links

- [SLSA Threats and mitigations](https://slsa.dev/spec/v1.0/threats) — supply chain threat model
- [CORE-0010 Unified Module Validation](CORE-0010 Unified Module Validation.md) — the validation script this decision protects

[SLSA-THREATS]: https://slsa.dev/spec/v1.0/threats
[SLSA-LEVELS]: https://slsa.dev/spec/v1.0/levels
