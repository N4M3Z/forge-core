# Provenance

Check whether rules cite external authoritative sources using GFM reference links (CORE-0017).

## What It Checks

Scan each `.md` file for `[N]:` reference link definitions. These should point to external sources — OWASP cheat sheets, CVEs, model advisories, team decisions, standards documents — not to other forge rules.

## Detection Pattern

Count lines matching `^\[\d+\]:` in the file body (after frontmatter).

| Count | Status  | Action                           |
|-------|---------|----------------------------------|
| 0     | Missing | Flag: "no external sources cited" |
| 1+    | Present | Report count and list URLs        |

## What Good Provenance Looks Like

```markdown
Always parameterize SQL queries [1].
Validate generated code for path traversal [2].

[1]: https://cheatsheetseries.owasp.org/cheatsheets/Query_Parameterization_Cheat_Sheet.html
[2]: https://cve.example.com/2026-1234
```

References point to external knowledge. At deploy time, `[N]` markers and the reference block are stripped (CORE-0017). The extracted URLs flow into the W3C PROV record (CORE-0020).

## What Bad Provenance Looks Like

- `[1]: forge-steering:rules/UseRTK.md` — self-referential, points to another rule
- No refs at all — the rule has no documented source
- `[1]: https://example.com` — placeholder URL

## Severity

Info — missing provenance is not a bug. Many rules are original conventions, not derived from external sources. The check flags the gap for human judgment.
