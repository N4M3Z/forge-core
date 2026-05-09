The `forge install` command (via `forge-cli`) transforms canonical source artifacts for each target provider using a standardized assembly pipeline.

### Assembly Pipeline

1. **Translation**: Converts Markdown agent files into provider-native formats (e.g., TOML for Gemini and Codex).
2. **Remapping**: Automatically translates standard tool names (e.g., `Read`, `Bash`, `Grep`) in `defaults.yaml` and agents into their native equivalents for each provider (e.g., `read_file`, `run_shell_command`).
3. **Cleanup**: Strips frontmatter, resolves companion files (`@`), and removes provenance markers to minimize token overhead in deployed files.

Authors MUST author using the canonical Markdown form and standard tool names. Never write provider-specific formats (TOML) or use native tool names directly in the source repository.

Assembly also rewrites provenance sidecars. Source-side `adopt/v1` sidecars (with upstream + AdoptArtifact dependencies) become `assemble/v1` sidecars at deploy, with a single-source input. The full adoption chain is preserved only in the source repo's `.provenance/` files. Audit deployed artifacts for tamper; audit source-repo sidecars for adoption history. See the [ProvenanceAudit][ProvenanceAudit] skill for operational procedures.

[ProvenanceAudit]: skills/ProvenanceAudit/SKILL.md
