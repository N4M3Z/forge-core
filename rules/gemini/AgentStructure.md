---
mode: append
---

**Gemini Specifics:**
Gemini CLI relies on a different security and tool paradigm than Claude. When authoring agents exclusively for Gemini:
- Do NOT include `mcpServers` in the frontmatter, as native MCP support is unavailable in Gemini CLI.
- `permissionMode` is currently ignored by Gemini CLI — permissions are governed by the tool access configuration in `defaults.yaml` (translated to the agent's `.toml` file).
- While you author using standard names (`Read`, `Bash`), the deployed agent in `.gemini/agents/` will use native Gemini tool names (`read_file`, `run_shell_command`) per [ArtifactComposition](../ArtifactComposition.md).

[GEMINI-CLI]: https://github.com/google-gemini/gemini-cli "Gemini CLI"
