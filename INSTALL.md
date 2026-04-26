# forge-core

> Module-building skills for the forge ecosystem. Teaches AI coding tools to create skills, scaffold agents, and architect modules.

*This file follows the [install.md](https://github.com/mintlify/install-md) standard — structured instructions for AI agents to execute autonomously. Human readers: see [README.md](README.md) for conventional documentation.*

I want you to install forge-core for me. Execute all the steps below autonomously.

## OBJECTIVE

Deploy forge-core skills, agents, and rules to all AI providers via Makefile.

## DONE WHEN

- `make validate` passes
- `ls ~/.claude/skills/BuildSkill/SKILL.md` confirms skill deployment
- `git config core.hooksPath` returns `.githooks`
- `~/.claude/settings.json` contains the `hooks` block with forge-core hook commands

## Prerequisites

- Claude Code (or another AI provider CLI)
- Rust toolchain (`rustup` + `cargo`) — [rustup.rs](https://rustup.rs)
- forge-cli (`cargo install` from source, see step below)

Without Rust: copy `skills/`, `agents/`, `rules/` into the provider config directory (e.g., `~/.claude/`) directly.

## TODO

- [ ] Install prerequisites (rustup, cargo)
- [ ] Clone the repository
- [ ] Install forge-cli
- [ ] Run `make install` to deploy
- [ ] Wire Claude Code hooks into `~/.claude/settings.json`
- [ ] Verify skill deployment
- [ ] Verify git hooks are active

## Steps

### Clone

```sh
git clone https://github.com/N4M3Z/forge-core.git
cd forge-core
```

If already cloned, pull latest:

```sh
git pull
```

### Check prerequisites

```sh
make validate
```

If `forge` shows MISSING, install forge-cli first:

```sh
git clone https://github.com/N4M3Z/forge-cli.git
cd forge-cli
make install
cd ../forge-core
```

### Install

```sh
make install
```

### Wire Claude Code hooks

`forge install` deploys skills, agents, and rules, but not hooks. Claude Code hooks must be wired manually into `~/.claude/settings.json`.

Read `hooks/hooks.json` in this repository: it lists every hook, its event, matcher, and command. For each entry, add a corresponding record to the `hooks` key in `~/.claude/settings.json`, replacing `${CLAUDE_PLUGIN_ROOT}` with the absolute path to your clone.

### Verify skill deployment

```sh
ls ~/.claude/skills/BuildSkill/SKILL.md
```

### Verify git hooks

```sh
git config core.hooksPath
```

Should return `.githooks`. Pre-commit hooks validate ADR frontmatter, shell scripts, Rust, Python, and TypeScript when staged files match.

EXECUTE NOW: Complete the above TODO list.
