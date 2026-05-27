---
name: BuildSkill
version: 0.1.0
description: "Create and validate skills for forge modules. USE WHEN create skill, new skill, write skill, validate skill, check skill, skill structure, skill conventions."
---

# BuildSkill

Create and validate skills following forge conventions. Skills are markdown files (`SKILL.md`) with YAML frontmatter that teach AI coding tools new capabilities. Load only the companion relevant to the current task.

## Workflow Routing

| Workflow     | Trigger                                          | Companion                                         |
| ------------ | ------------------------------------------------ | ------------------------------------------------- |
| Create       | "create a skill", "new skill", "write a skill"   | [@CreateWorkflow.md](CreateWorkflow.md)             |
| Validate     | "validate skill", "check skill structure"        | [@ValidateWorkflow.md](ValidateWorkflow.md)         |

## Topics

| Topic                                                       | Companion                                                |
| ----------------------------------------------------------- | -------------------------------------------------------- |
| SKILL.md structure, frontmatter, body layout, naming        | [@SkillStructure.md](SkillStructure.md)                    |
| Multi-provider routing via `defaults.yaml`                  | [@MultiProviderRouting.md](MultiProviderRouting.md)        |
| Wrapping a CLI tool in a skill                              | [@CliToolIntegration.md](CliToolIntegration.md)            |
| Platform-agnostic writing — no placeholders or `/` prefix   | [@PlatformAgnostic.md](PlatformAgnostic.md)                |
| When to author a per-skill INSTALL.md                       | [@SkillInstallation.md](SkillInstallation.md)              |

## Red Flags

| Thought                                                  | Reality                                                                              |
| -------------------------------------------------------- | ------------------------------------------------------------------------------------ |
| "Put argument-hint in SKILL.md frontmatter"              | Obsidian Linter reformats frontmatter. Provider-specific fields go in SKILL.yaml.     |
| "Use `/SkillName` inside a skill body"                   | Slashes are user-facing invocation syntax, not internal references.                    |
| "Skip the `USE WHEN` clause"                             | Claude uses it to route. Missing trigger = skill never fires.                         |
| "Leave a stub section as a placeholder"                  | Skill bodies are plain prose. Delete empty sections, don't scaffold them.             |
| "Inline every example in the SKILL.md"                   | SKILL.md should stay slim. Move static reference material to companion files.         |
| "Skill directory can have any name"                      | Directory name must match the `name:` frontmatter field exactly.                      |

## Constraints

- Every skill MUST have `name:` and `description:` in frontmatter
- Description MUST include `USE WHEN` trigger phrases
- PascalCase for multi-word skill names, natural case for single words
- Skill directory name must match the `name:` field
- Prefer one SKILL.md per skill — extract reference material into companion files when body exceeds ~150 lines or contains dense static data

## Sources

- <https://code.claude.com/docs/en/skills>
- <https://github.com/anthropics/skills>
