# forge-core

> Module-building skills for the forge ecosystem. Teaches AI coding tools to create skills, scaffold agents, and architect modules.

*This file follows the [install.md](https://github.com/mintlify/install-md) standard — structured instructions for AI agents to execute autonomously. Human readers: see [README.md](README.md) for conventional documentation.*

I want you to install forge-core for me. Execute all the steps below autonomously.

## OBJECTIVE

Deploy forge-core skills, agents, and rules to all AI providers via Makefile.

## DONE WHEN

`make check` reports all items OK and `ls ~/.claude/skills/BuildSkill/SKILL.md` confirms deployment.

## TODO

- [ ] Clone the repository
- [ ] Run `make check` to verify prerequisites
- [ ] Run `make install` to deploy
- [ ] Verify deployment

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
make check
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

### Verify

```sh
ls ~/.claude/skills/BuildSkill/SKILL.md
```

EXECUTE NOW: Complete the above TODO list to achieve: `make check` reports all items OK and `ls ~/.claude/skills/BuildSkill/SKILL.md` confirms deployment.
