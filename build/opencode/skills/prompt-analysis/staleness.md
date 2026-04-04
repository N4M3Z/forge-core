# Staleness

Check whether rules reference deprecated model identifiers, removed APIs, or outdated practices.

## What It Checks

Regex scan of file body for known deprecated patterns.

## Detection Patterns

### Deprecated Model Identifiers

```regex
gpt-3\.5|gpt-4(?!o)|text-davinci|claude-2|claude-instant|claude-3(?!\.)
```

Matches: `gpt-3.5`, `gpt-4` (but not `gpt-4o`), `text-davinci`, `claude-2`, `claude-instant`, `claude-3` (but not `claude-3.5`).

### Deprecated Tool References

| Pattern                     | Replacement                                              |
|-----------------------------|----------------------------------------------------------|
| `TodoWrite`                 | deprecated in Claude Code — use `TaskCreate`/`TaskUpdate` |
| `WebSearch` (as a tool name)| verify current tool name for active provider              |

### Deprecated API Patterns

| Pattern                           | Issue                        |
|-----------------------------------|------------------------------|
| `api.openai.com/v1/completions`   | legacy completions endpoint  |
| `anthropic.com/v1/complete`       | legacy Claude API            |

## Adding New Patterns

When a model or API is deprecated, add the pattern to this file. The skill reads this companion at invocation time — no code change needed.

## Severity

Error — stale references actively mislead the model. A rule referencing `claude-2` capabilities may give wrong guidance for `claude-opus-4-6`.

## Limitations

The patterns are manually maintained. There is no automated feed of deprecated model IDs or APIs. When a new model ships and an old one is deprecated, someone needs to add the pattern here.
