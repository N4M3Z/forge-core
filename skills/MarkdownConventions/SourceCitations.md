## SourceCitations

Every factual data point (number, date, limit, rate, threshold) carries a reference-style citation. Unsourced claims are unreliable and unverifiable.

### Format

Inline reference paired with a label definition at the bottom of the file:

```markdown
OWASP lists SQL injection as #1 in the top 10 ([2021 list][OWASP]).

[OWASP]: https://owasp.org/Top10/
```

Labels are mnemonic abbreviations derived from the source name (`[OWASP]`, `[MADR]`, `[RFC7519]`), never numbers.

### Examples

Bad (missing citation, reader cannot verify):

```markdown
OWASP lists SQL injection as #1 in the top 10.
```

Bad (numeric label, unreadable at the call site):

```markdown
OWASP lists SQL injection as #1 in the top 10 ([source][1]).

[1]: https://owasp.org/Top10/
```

### Constraints

- Place reference definitions at the bottom of the file, grouped in one block.
- Reuse the same label across multiple citations of the same source within a file.
