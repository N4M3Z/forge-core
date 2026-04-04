# Targeting

Check whether rules are correctly targeted to the providers and models they apply to (PROV-0005).

## What It Checks

Two things: does the file contain provider-specific content, and if so, does it have matching `targets:` frontmatter or qualifier directory variants?

## Detection Pattern

Scan the file body for provider-specific keywords. If any match and no `targets:` frontmatter exists, flag as missing targets.

### Provider Keyword Table

| Provider | Keywords                                                                                                                                                     |
|----------|--------------------------------------------------------------------------------------------------------------------------------------------------------------|
| claude   | `Read tool`, `Edit tool`, `Write tool`, `Bash tool`, `Agent tool`, `TeamCreate`, `SendMessage`, `Claude Code`, `rtk`, `CLAUDE.md`, `dangerouslyDisableSandbox` |
| codex    | `Codex CLI`, `AGENTS.md`, `codex`                                                                                                                            |
| gemini   | `Gemini CLI`, `@AgentName`, `GEMINI.md`                                                                                                                      |
| openai   | `ChatGPT`, `GPT`                                                                                                                                             |

These are heuristics. False positives are possible (a rule discussing Claude Code conceptually, not targeting it). Flag for review, not automatic action.

### Qualifier Directory Check

For each base rule with provider-specific content, check if qualifier variants exist:

```
rules/
  AgentTeams.md            ← base, references TeamCreate
  codex/AgentTeams.md      ← variant exists ✓
  gemini/AgentTeams.md     ← variant exists ✓
```

If provider-specific content exists but no variants: flag as "qualifier split recommended."

## Severity

Warning — provider-specific content without targeting means the rule deploys to providers where it's irrelevant, wasting tokens.

## What Good Targeting Looks Like

**Include/exclude** (same content, some providers skip it):
```yaml
---
targets: [claude, codex]
---
Always prefix shell commands with `rtk`...
```

**Content variants** (different content per provider):
```
rules/
  AgentTeams.md              ← base for claude/opencode
  codex/AgentTeams.md        ← codex-specific workaround
  gemini/AgentTeams.md       ← gemini-specific workaround
```

The `targets:` field also serves as a reconstructibility record — if qualifier directories are lost, frontmatter documents which providers the rule was meant for.
