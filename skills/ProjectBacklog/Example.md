# Example

`docs/todos/2026-04-27.md`:

```markdown
# Todos — 2026-04-27

- [ ] Refactor config loader to typed serde deserialization [priority:: high] [id:: 0002] #refactor #rust
    - Current loader uses chained `.get()` on untyped YAML and silently falls back to defaults.
    - Acceptance: `Config` struct deserializes via serde; schema mismatches surface as parse errors; existing fixtures load unchanged.
    - Related: [[0007 Typed Configuration]]

- [/] Document INSTALL.md verification step [priority:: medium] [id:: 0001] #docs
    - Add a DONE WHEN clause that runs `make check` and reports pass/fail.
```

`docs/todos/2026-04-22.md`:

```markdown
# Todos — 2026-04-22

- [x] Wire pre-commit hook into the validation chain [priority:: high] [id:: 0000] [completion:: 2026-04-25] #setup
    - Closed by commit `abc1234`.
```

Closed items stay in the daily file where they were captured. Querying open work means filtering by `- [ ]` and `- [/]` across all daily files.
