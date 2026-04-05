# Provenance

Check whether rules cite external authoritative sources using GFM reference links (PROV-0004).

## What It Checks

Scan each `.md` file for mnemonic reference link definitions. These should point to external sources — OWASP cheat sheets, CVEs, model advisories, team decisions, standards documents — not to other forge rules.

## Detection Pattern

Count lines matching `^\[[A-Z][-A-Z0-9]*\]:` in the file body (after frontmatter).

| Count | Status  | Action                           |
|-------|---------|----------------------------------|
| 0     | Missing | Flag: "no external sources cited" |
| 1+    | Present | Report count and list URLs        |

## What Good Provenance Looks Like

```markdown
Always parameterize SQL queries [OWASP].
Validate generated code for path traversal [CVE-1234].

[OWASP]: https://cheatsheetseries.owasp.org/cheatsheets/Query_Parameterization_Cheat_Sheet.html
[CVE-1234]: https://cve.example.com/2026-1234
```

References point to external knowledge. At deploy time, reference markers and the reference block are stripped (PROV-0004). The extracted URLs flow into the provenance record (PROV-0003).

## What Bad Provenance Looks Like

- `[USERTK]: forge-steering:rules/UseRTK.md` — self-referential, points to another rule
- No refs at all — the rule has no documented source
- `[EXAMPLE]: https://example.com` — placeholder URL

## Severity

Info — missing provenance is not a bug. Many rules are original conventions, not derived from external sources. The check flags the gap for human judgment.
