---
name: CitationHygiene
version: 0.1.0
description: "Cite origins for every factual data point (number, date, limit, rate, threshold) via markdown reference-style links. USE WHEN writing docs, ADRs, READMEs, or any file that asserts factual claims."
paths:
    - "docs/**/*.md"
    - "README.md"
    - "ARCHITECTURE.md"
---

# CitationHygiene

Every factual data point (number, date, limit, rate, threshold) must cite its origin via a markdown reference-style link. Unsourced claims are unreliable and unverifiable.

## Format

Inline reference: `([source][OWASP])` with `[OWASP]: https://...` at the bottom of the file. Labels are mnemonic abbreviations derived from the source name, not numbers.

## Examples

Good:

```markdown
OWASP lists SQL injection as #1 in the top 10 ([2021 list][OWASP]).

[OWASP]: https://owasp.org/Top10/
```

Bad:

```markdown
OWASP lists SQL injection as #1 in the top 10.
```

(Missing citation — reader cannot verify.)

```markdown
OWASP lists SQL injection as #1 in the top 10 ([source][1]).

[1]: https://owasp.org/Top10/
```

(Numeric label — unreadable at the call site.)

## Constraints

- Every number, date, limit, rate, or threshold in prose needs a source
- Use mnemonic abbreviations (`[OWASP]`, `[MADR]`, `[RFC7519]`) — not `[1]`, `[2]`
- Place reference definitions at the bottom of the file, grouped in one block
- Reuse the same label across multiple citations of the same source within a file
