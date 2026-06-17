# Gemini Agent Deployment

When scaffolding agents for Gemini CLI, author them exactly the same way as Claude Code agents (Markdown files in `agents/`).

## Deployment Translation

The `forge install` command (via `forge-cli`) handles the translation to Gemini's expected format. Following [NoVendorLockIn](../../rules/NoVendorLockIn.md), the build system performs:

1. **Name Slugification**: Deploys the `.md` file under a slugified filename (`DataAnalyst.md` becomes `data-analyst.md`) into `.gemini/agents/`.
2. **Tool Mapping**: Translates standard tool names used in `defaults.yaml` to their Gemini-native equivalents.

### Tool Mapping Reference

| Standard Tool | Gemini Equivalent |
|---------------|-------------------|
| `Read`        | `read_file`       |
| `Bash`        | `run_shell_command` |
| `Grep`        | `grep_search`     |
| `Glob`        | `glob`            |
| `Write`       | `write_file`      |
| `Edit`        | `replace`         |

Authors should NOT manually use Gemini tool names in `defaults.yaml` or write raw `.toml` files in the source repository. Keep the source repository platform-agnostic.

[GEMINI-CLI]: https://github.com/google-gemini/gemini-cli "Gemini CLI"