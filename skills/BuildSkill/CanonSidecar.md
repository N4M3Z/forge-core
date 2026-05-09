Module skills use two files side by side:

| File         | Purpose                                | Contains                                           |
| ------------ | -------------------------------------- | -------------------------------------------------- |
| `SKILL.md`   | **Canon** — frontmatter + skill body   | `name:`, `description:`, `version:`, instructions  |
| `SKILL.yaml` | **Sidecar** — everything else          | `sources:`, provider keys, Obsidian metadata       |

**SKILL.yaml must NOT duplicate SKILL.md fields** — no `name:` or `description:` in the sidecar. It carries supplementary data:

```yaml
sources:                              # upstream documentation links
    - https://example.com/docs

claude:                               # merged into installed SKILL.md frontmatter
    argument-hint: "[file path]"      # hint shown during / autocomplete
    disable-model-invocation: true    # prevents Claude auto-loading
    user-invocable: false             # hides from / menu
    allowed-tools: Read, Grep, Glob   # tools usable without permission
    model: claude-sonnet-4-6          # model override when skill is active
    context: fork                     # run in subagent context
    agent: Explore                    # subagent type (with context: fork)

user:                                 # free-form namespace (personal metadata)
    priority: high
```

**`claude:` key details:** `forge install` reads all key-value pairs under `claude:` and merges them into the installed SKILL.md frontmatter. Any [Claude Code skill frontmatter field](https://code.claude.com/docs/en/skills) can go here. Put them in the sidecar instead of SKILL.md to protect them from Obsidian Linter reformatting. Codex uses TOML-based [multi-agent configuration](https://developers.openai.com/codex/multi-agent/), not YAML skill frontmatter — check the provider docs for the latest supported keys.

The sidecar is also the landing zone for Obsidian Linter — any `title:`, `aliases:`, `tags:`, or other vault metadata the Linter injects lands here, not in the canon. The `user:` namespace is free-form for personal metadata.

**Minimal sidecar** (skills without external references or provider-specific config):

```yaml
sources: []
```

Every SKILL.yaml must have `sources:` even if empty. Add `claude:` keys only when needed (argument-hint, model override, etc.).

## Example file

Skills should ship with an `Example.md` demo file showing a concrete invocation and expected output. This makes each skill self-documenting and demoable without reading the full SKILL.md.

**Why separate files?** Obsidian's Linter reformats frontmatter on save — it adds `title:`, reorders keys, and may strip unrecognized fields like `name:`. Separating prevents cross-contamination.
