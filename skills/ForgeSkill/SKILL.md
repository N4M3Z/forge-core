---
name: ForgeSkill
version: 0.1.0
description: "Create, validate, evaluate, and iterate skills for forge modules. USE WHEN create skill, new skill, write skill, validate skill, check skill, skill structure, skill conventions, test a skill, run skill evals, benchmark a skill, skill not triggering, optimize skill description. Not for adopting community skills (AdoptArtifact) or shipping artifacts downstream (PublishArtifact)."
upstream: https://github.com/anthropics/skills/blob/main/skills/skill-creator/SKILL.md
---

# ForgeSkill

Create, validate, evaluate, and iterate skills following forge conventions. Skills are markdown files (`SKILL.md`) with YAML frontmatter that teach AI coding tools new capabilities. Load only the companion relevant to the current task.

The evaluation machinery (grader/comparator/analyzer prompts, eval scripts, browser viewer) lives in `agents/`, `scripts/`, `references/`, `eval-viewer/`, and `assets/`. Scripts run with `python -m scripts.<name>` from this skill's directory (`${CLAUDE_SKILL_DIR}` when deployed). The files under `agents/` are worker prompt templates this skill feeds to generic subagents during the eval loop, not standalone agent definitions; harness-discoverable agents belong in the module-level `agents/` directory.

## Workflow Routing

| Workflow           | Trigger                                                      | Companion                                                 |
| ------------------ | ------------------------------------------------------------ | --------------------------------------------------------- |
| Create             | "create a skill", "new skill", "write a skill"               | [@CreateWorkflow.md](CreateWorkflow.md)                     |
| Validate           | "validate skill", "check skill structure"                    | [@ValidateWorkflow.md](ValidateWorkflow.md)                 |
| Evaluate           | "test this skill", "run skill evals", "benchmark the skill"  | [@EvalLoop.md](EvalLoop.md)                                 |
| Optimize triggering | "skill doesn't trigger", "improve the skill description"     | [@DescriptionOptimization.md](DescriptionOptimization.md)  |

## Topics

| Topic                                                       | Companion                                                |
| ----------------------------------------------------------- | -------------------------------------------------------- |
| SKILL.md structure, frontmatter, body layout, naming        | [@SkillStructure.md](SkillStructure.md)                    |
| **Dynamic context injection (`!`): open a Claude skill with live state** | [@DynamicContextInjection.md](DynamicContextInjection.md) |
| Multi-provider routing via `defaults.yaml`                  | [@MultiProviderRouting.md](MultiProviderRouting.md)        |
| Wrapping a CLI tool in a skill                              | [@CliToolIntegration.md](CliToolIntegration.md)            |
| Platform-agnostic writing — no placeholders or `/` prefix   | [@PlatformAgnostic.md](PlatformAgnostic.md)                |
| User-config schema for AI-first artifacts (autoMode mirror) | [@UserConfigSchema.md](UserConfigSchema.md)                |
| Claude-only features: `@` refs, skill discovery, `allowed-tools` | [@ClaudeSkill.md](ClaudeSkill.md)              |
| When to author a per-skill INSTALL.md                       | [@SkillInstallation.md](SkillInstallation.md)              |
| Eval JSON structures (evals.json, grading.json, benchmark.json) | [@references/schemas.md](references/schemas.md)        |

## Red Flags

| Thought                                                  | Reality                                                                              |
| -------------------------------------------------------- | ------------------------------------------------------------------------------------ |
| "Put argument-hint in SKILL.md frontmatter"              | Obsidian Linter reformats frontmatter. Provider-specific fields go in SKILL.yaml.     |
| "Use `/SkillName` inside a skill body"                   | Slashes are user-facing invocation syntax, not internal references.                    |
| "Skip the `USE WHEN` clause"                             | Claude uses it to route. Missing trigger = skill never fires.                         |
| "Leave a stub section as a placeholder"                  | Skill bodies are plain prose. Delete empty sections, don't scaffold them.             |
| "Inline every example in the SKILL.md"                   | SKILL.md should stay slim. Move static reference material to companion files.         |
| "Skill directory can have any name"                      | Directory name must match the `name:` frontmatter field exactly.                      |
| "Put a `!` injection in a companion file"                | `!` runs only in the SKILL.md body; in a companion it renders as literal text. See [@ClaudeSkill.md](ClaudeSkill.md). |
| "Inject a secret value with `!` (e.g. `pass show`)"      | Injection lands in the transcript. Inject structure/status (names, vault list), never secret values. |
| "It ran in my sandbox, so the probe is done"             | Your sandbox has tooling (uv, personal paths, aliases) the target machine lacks — resolve interpreters at preflight and assume a clean environment. |
| "I'll write custom HTML to show eval results"            | `eval-viewer/generate_review.py` already renders outputs and benchmarks. Use it.      |
| "The skill passed its three evals, ship it"              | A handful of examples overfits. Generalize the fix; don't patch the skill to the test set. |

## Constraints

- Every skill MUST have `name:` and `description:` in frontmatter
- Description MUST include `USE WHEN` trigger phrases
- PascalCase for multi-word skill names, natural case for single words
- Skill directory name must match the `name:` field
- Prefer one SKILL.md per skill — extract reference material into companion files when body exceeds ~150 lines or contains dense static data
- Eval artifacts land in `<skill-name>-workspace/` as a sibling of the skill directory, never inside the skill

## Sources

- <https://code.claude.com/docs/en/skills>
- <https://github.com/anthropics/skills>
