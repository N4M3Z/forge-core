Templates use `${VARIABLE}` placeholders resolvable by `envsubst` or shell parameter expansion. Obsidian Templater templates use `{{VARIABLE}}` instead — the two patterns do not mix within a single file.

End-of-line `%%` comments describe what each variable should contain. Align comments to a consistent column for readability. Enum choices use `|` separators inside the comment:

```markdown
status: ${STATUS}                          %% proposed | accepted | deprecated | superseded %%
category: ${CATEGORY}                      %% architecture, process, governance, security %%
- [+] ${POSITIVE}                          %% positive outcome — what improves %%
```

Variable names are UPPER_SNAKE_CASE. Names should be self-documenting — `${OPTION_1_DESCRIPTION}` not `${DESC}`. The comment adds context the name alone cannot convey (valid values, sentence length, relationship to other fields).

When generating files programmatically (Makefile, YAML, config), embed the template via `include_str!` (Rust) or equivalent and substitute variables at runtime. Don't build content with `format!()` or string concatenation — it's harder to test, harder to read, and whitespace-sensitive output (Make recipes need tabs) gets mangled by Rust's auto-formatter or other tooling. Same principle as test fixtures (see InertFixtures): file content lives in files, not inline strings.
