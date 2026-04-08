Forge modules follow the **Agent Skills** ([agentskills.io][SKILLS]) standard for cross-provider compatibility.

Modules produce three artifact types:
- **Rules**: Always loaded behavioral instructions.
- **Skills**: Lazy-loaded capabilities invoked by the AI.
- **Agents**: Persona definitions for delegation.

Each artifact is authored once as Markdown in its respective directory (`rules/`, `skills/`, or `agents/`).

Assembly transforms these canonical sources for each target provider — see [CrossProviderAssembly][CrossProviderAssembly.md] for the assembly pipeline specifics.

[SKILLS]: https://agentskills.io "Agent Skills Standard"
