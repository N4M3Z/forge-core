No AI vendor is a single point of failure: artifacts are authored once in canonical form and compiled per harness, so any vendor can fail, reprice, or be replaced without rewriting content.

`forge install` performs the compilation: Markdown agents become each harness's native format (TOML for Codex, slugified Markdown for Gemini), standard tool names (`Read`, `Bash`, `Grep`) in `defaults.yaml` and agents are remapped to native equivalents (`read_file`, `run_shell_command`), and frontmatter, `@` companion references, and provenance markers are stripped from deployed files.

Author only the canonical Markdown form with standard tool names. Never write harness-specific formats (TOML) or native tool names in the source repository.

Assembly also rewrites provenance sidecars (`adopt/v1` becomes `assemble/v1` at deploy); the [ProvenanceAudit][ProvenanceAudit] skill covers the layering and audit procedures.

[ProvenanceAudit]: skills/ProvenanceAudit/SKILL.md
