Timestamp format: `YYYY-MM-DD HH:MM` (example: `2026-12-31 23:11`). Based on ISO 8601 / [RFC 3339][RFC3339] extended date-time, with the space separator permitted by [§5.6][RFC3339-5.6]. The zone designator is omitted because all timestamps are UTC by convention.

For backup or version suffixes, use the date-only form `YYYY-MM-DD` (example: `settings.json.2026-05-13.bak`). Daily-rotation files like journal entries and ADR identifiers also use the date-only form.

UTC is the only acceptable timezone. Never use local time. If a zone designator is needed for disambiguation, use the canonical `Z` per RFC 3339, never `UTC` as a literal.

[RFC3339]: https://datatracker.ietf.org/doc/html/rfc3339 "RFC 3339, Date and Time on the Internet: Timestamps"
[RFC3339-5.6]: https://datatracker.ietf.org/doc/html/rfc3339#section-5.6 "RFC 3339 §5.6, Internet Date/Time Format"
