---
title: Reference Links for Prompt Provenance
description: Reference-style links provide auditable provenance in source files, stripped at deploy for zero token overhead
type: adr
category: architecture
tags:
    - architecture
    - provenance
    - markdown
status: accepted
created: 2026-03-15
updated: 2026-03-30
author: "@N4M3Z"
project: forge-core
related:
    - "PROV-0003 Provenance Tracking.md"
responsible: ["@N4M3Z"]
accountable: ["@N4M3Z"]
consulted: []
informed: []
upstream: []
---

# Reference Links for Prompt Provenance

## Context and Problem Statement

AI instructions need traceable provenance — where did this knowledge come from? ISO 42001, NIST AI RMF, and the EU AI Act require traceability but prescribe no format. Deployed prompts must remain token-clean. References should point to external authoritative sources (CVEs, OWASP, model advisories), not self-referentially to other rules.

## Considered Options

- **Reference-style links** — `[OWASP]: https://owasp.org/...` in source, stripped at deploy
- **Sidecar-only** — companion file carries all provenance metadata
- **Inline HTML comments** — invisible in rendered markdown
- **Extended frontmatter injected at deploy** — install binary adds metadata to deployed files

## Decision Outcome

Chosen option: **Reference-style links**, because they're standard markdown, human-readable in source, and the install binary can strip them at deploy for zero token overhead. Stripping is configurable (`--provenance strip|inline`). External URLs extracted from stripped refs feed into provenance tracking records ([PROV-0003](PROV-0003 Provenance Tracking.md)).

```markdown
Always parameterize SQL queries [OWASP].

[OWASP]: https://cheatsheetseries.owasp.org/cheatsheets/Query_Parameterization_Cheat_Sheet.html
```

## Consequences

- Positive: source files are self-documenting with auditable provenance
- Positive: deployed files remain token-clean when stripping is enabled
- Tradeoff: rules that cite external sources need mnemonic reference blocks added
