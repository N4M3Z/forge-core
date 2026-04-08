Gemini CLI supports the full range of forge artifacts with no silent dropping of instructions or background context.

**Supported Artifacts:**
- **Rules**: Global and provider-specific rules in `.gemini/rules/` are always in context.
- **Skills**: Lazy-loaded capabilities in `.gemini/skills/` are available for user or agent invocation.
- **Agents**: Persona definitions in `.gemini/agents/` are available for task delegation via `@AgentName` syntax.
- **Modular Context**: Supports the `@./path.md` import syntax for clean, composable instructions.

[GEMINI-CLI]: https://github.com/google-gemini/gemini-cli "Gemini CLI"
