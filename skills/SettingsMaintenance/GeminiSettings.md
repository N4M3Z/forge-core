# Gemini Settings Maintenance

Audit and clean Gemini CLI configuration files. Gemini CLI uses a simpler configuration model than Claude Code.

## Settings Architecture

Gemini CLI stores settings in JSON format. It typically uses:
- Global: `~/.gemini/settings.json`
- Project: `.gemini/settings.json`

## Audit Checklist

1. **Model Assignments**:
   Check the `models` or `model` configuration strings.
   - Verify that `gemini-2.5-pro` is assigned for complex reasoning tasks (strong tier).
   - Verify that `gemini-2.0-flash` is assigned for faster, simpler tasks (fast tier).

2. **Tool Bindings**:
   Ensure that the allowed tools list correctly maps to Gemini's native tool names:
   - `read_file`, `write_file`, `replace`, `grep_search`, `run_shell_command`, `glob`.
   - Flag any Anthropic-specific tool names (e.g., `Bash`, `Grep`, `Read`, `Edit`) as invalid cruft to be removed.

3. **Context Window Limits**:
   Check for any configured limits that aggressively truncate context. Recommend removing them to take full advantage of Gemini 1.5's 1M+ token context window.

4. **Environment Variables**:
   Verify that `GEMINI_API_KEY` is present in the environment or configuration.

[GEMINI-CLI]: https://github.com/google-gemini/gemini-cli "Gemini CLI"