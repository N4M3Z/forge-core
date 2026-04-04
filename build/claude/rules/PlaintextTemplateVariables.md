Templates use `${VARIABLE}` placeholders resolvable by `envsubst` or shell parameter expansion. Obsidian Templater templates use `{{VARIABLE}}` instead — the two patterns do not mix within a single file.

End-of-line `%%` comments describe what each variable should contain. Align comments to a consistent column for readability. Enum choices use `|` separators inside the comment:

```markdown
status: ${STATUS}                          %% proposed | accepted | deprecated | superseded %%
category: ${CATEGORY}                      %% architecture, process, governance, security %%
- [+] ${POSITIVE}                          %% positive outcome — what improves %%
```

Variable names are UPPER_SNAKE_CASE. Names should be self-documenting — `${OPTION_1_DESCRIPTION}` not `${DESC}`. The comment adds context the name alone cannot convey (valid values, sentence length, relationship to other fields).