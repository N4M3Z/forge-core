# Verify

> **For AI agents**: Complete this checklist after installation.

## Health check

```bash
make verify
```

Check skills are deployed to at least one provider:

```bash
ls .claude/skills/*/SKILL.md 2>/dev/null | wc -l
# Expected: 8 (BuildSkill, BuildAgent, BuildModule, BuildHook, MarkdownLint, Sessions, Permissions, RTK)
```

## Structure validation

```bash
make test
# Runs validate-module against the module structure
```

Check key files exist:

```bash
test -f module.yaml && echo "ok module.yaml"
test -f .claude-plugin/plugin.json && echo "ok plugin.json"
test -f defaults.yaml && echo "ok defaults.yaml"
test -f lib/Cargo.toml && echo "ok forge-lib submodule"
```

## Success criteria

- [ ] `make verify` passes with no errors
- [ ] 8 skills deployed to `.claude/skills/`
- [ ] `make test` passes (validate-module convention checks)
- [ ] forge-lib submodule initialized (`lib/Cargo.toml` exists)
