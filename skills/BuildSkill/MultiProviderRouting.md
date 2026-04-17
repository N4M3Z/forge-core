Provider routing is controlled by the module's `defaults.yaml`, not by individual SKILL.yaml files. `forge install` reads provider-keyed allowlists to decide which skills deploy where:

```yaml
# defaults.yaml
skills:
    claude:
        SkillName:
    gemini:
        SkillName:
    codex:
        SkillName:
    opencode:
        SkillName:
```

Skills listed under a provider key are installed for that provider. Skills omitted from a provider's list are skipped. This allows Claude-only skills (e.g., those using TeamCreate or agent teams) to be excluded from Gemini/Codex/OpenCode without per-skill configuration.
