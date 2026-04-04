---
name: AdaptPrompts
description: "Adapt generic rules and prompts for independent repos — strip forge branding, add path scoping, drop irrelevant rules, preserve custom overrides. USE WHEN adapt rules, adapt prompts, port rules, specialize rules, sync rules, update rules for repo, rules for proton, rules for lb-agent."
version: 0.1.0
---
Take a source rule set and adapt it for a target repo that consumes the lib submodule as infrastructure but has its own identity.

## Instructions

1. Read the target repo's `rules/` directory. Classify each file:
   - **Custom** — exists only in the target (e.g., `IndustrySecrets.md`, `ScanRepository.md`). Never touch these.
   - **Adapted** — same filename as a source rule but with modifications (`paths:` frontmatter, content changes). Preserve the adaptation, update the base content if the source changed.
   - **Identical** — exact copy of a source rule. Candidate for update or removal.
   - **Missing** — source rule has no counterpart in the target. Candidate for addition.

2. Read the source rule set. Default source: the module that owns this skill (`forge-core/rules/`). The user can specify a different source.

3. For each source rule, decide relevance to the target:

   | Rule type | Action |
   |-----------|--------|
   | Generic development (KeepChangelog, KeepCodeowners, UseRTK, GitConventions, LessIsMore, PlatformAgnostic, SanitizeData) | Port — these apply to any repo |
   | Module-specific (ChooseLicense, MakefileFirst, AuthorInModules, CanonSidecar, SkillNaming) | Skip unless the target is a forge module |
   | Forge-branded (ContextualNaming) | Skip — meta-rule about adaptation itself |
   | Provider-specific (CodexAgents, GeminiAgents, AgentTeams) | Port only if the target uses agents |
   | Memory/tooling (MemoryFiles, KnownIssues, ShellAliases) | Port only if relevant to the target's stack |

4. For each rule being ported, apply these transformations:

   - **Strip forge branding** per ContextualNaming: "forge-cli" becomes "the CLI tool", "forge-core" becomes "the core module", skill names drop forge prefix.
   - **Add `paths:` frontmatter** when the rule should be scoped (e.g., `SelfLearning.md` scoped to the target's skill paths).
   - **Preserve existing adaptations** — if the target already has a modified version, merge source updates into the existing adaptation rather than overwriting.
   - **Match the target's naming** — if the target uses different filenames, rename accordingly.

5. Present the adaptation plan as a table before making changes:

   ```
   | Source rule | Target status | Action | Notes |
   |-------------|---------------|--------|-------|
   | UseRTK.md | Identical copy (old name RTK.md) | Rename + update | Content unchanged |
   | KeepChangelog.md | Missing | Add | Generic, applies to any repo |
   | ChooseLicense.md | N/A | Skip | Module-specific |
   ```

6. Ask the user to confirm before writing. Apply changes with the Write tool.

7. After writing, list the final `rules/` directory contents grouped by origin:
   - Custom (target-only)
   - Adapted (source + modifications)
   - Ported (source, unmodified)

## Constraints

- Never overwrite custom rules — they represent domain knowledge that doesn't exist in the source
- Never add forge branding to non-forge repos — the target's identity is its own
- Always present the plan before writing — no silent rule installation
- Adapted rules keep the target's modifications; only the base content updates from source
- If a rule was renamed in the source (e.g., `RTK.md` → `UseRTK.md`), rename in the target too