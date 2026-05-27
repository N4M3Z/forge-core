---
title: "Forge Naming Collisions"
description: "Inventory of other CLIs named 'forge' and the chosen ~/.config/forge/ coexistence pattern"
type: adr
category: architecture
tags:
    - architecture
    - ecosystem
    - naming
status: accepted
created: 2026-05-25
updated: 2026-05-25
author: "@N4M3Z"
project: forge-core
related:
    - "ARCH-0008 Multi-Provider Support.md"
responsible: ["@N4M3Z"]
accountable: ["@N4M3Z"]
consulted: []
informed: []
upstream: []
---

# Forge Naming Collisions

## Context and Problem Statement

The name `forge` is crowded across the developer-tools ecosystem. A user who installs forge-cli alongside other `forge`-named tools shares both the `forge` binary name on `$PATH` and, potentially, the `~/.config/forge/` directory. Before forge artifacts started reading per-user runtime data from `~/.config/forge/<artifact>.{ext}` (see [UserConfig][UC] rule), the convention needed to be checked against tools already claiming that path.

## Decision Drivers

- Avoid silent filesystem collisions with established tools
- Preserve a clean user experience for the common case (user has only forge-cli installed)
- Follow XDG Base Directory Spec — `~/.config/<tool>/` is the canonical home for a tool literally named `<tool>`
- Leave room for forge-cli itself to grow XDG-aware settings later

## Considered Options

1. **`~/.config/forge/` with reserved `config*` filenames** — Canonical XDG. Coexists file-by-file with [git-pkgs/forge][GP] (which owns the literal filename `config`). forge-cli artifacts use artifact-named files (`forensic.yaml`, `avatar.yaml`); no overlap. Reservation of `config*` keeps the door open for forge-cli's own settings.
2. **`~/.config/forge.d/`** — Subdirectory marker. Zero collision risk but non-standard; XDG tools normally use plain `~/.config/<name>/`.
3. **`~/.config/forge-framework/`** — Fully branded. No collision risk, but verbose and drifts from the binary name.

## Decision Outcome

Chosen option: **`~/.config/forge/` with reserved `config*` filenames**. Documented in the [UserConfig][UC] rule. Artifact filenames must never start with `config`.

## Existing tools named `forge`

| Tool | Purpose | Config path | Collision with our convention |
| ---- | ------- | ----------- | ----------------------------- |
| [forge-cli][FC] | Module dispatcher and skill assembler for AI coding tools (this project) | `<module>/defaults.yaml`, `<module>/config.yaml`, and now `~/.config/forge/<artifact>.{ext}` | n/a — this is the convention |
| [git-pkgs/forge][GP] | Go-based unified CLI for GitHub/GitLab/Gitea/Forgejo | `~/.config/forge/config` (INI, respects `$XDG_CONFIG_HOME`) | Same directory, different filename. Coexists because `config*` is reserved on our side. |
| [Foundry `forge`][FD] | Ethereum/Solidity build, test, and deployment tool. Largest user base of any `forge` binary. | `~/.foundry/foundry.toml` (global) plus `foundry.toml` per project. Override via `FOUNDRY_CONFIG`. | No filesystem collision. Binary-name collision on `$PATH` resolves via PATH ordering. |
| [ForgeCode (`@antinomyhq/forge`)][AN] | AI pair programmer distributed via npm | `~/forge/.forge.toml`, optional `$FORGE_CONFIG` override | No filesystem collision. Binary `forge` on `$PATH` collides; rename or alias on the user's side. |
| [Homebrew `forge`][HB] | ArrayFire visualization C++ library (not a CLI with config) | none | None. |
| [Atlassian Forge CLI (`@forge/cli`)][AF] | Build tool for Atlassian apps | per-project node config | None. |
| Electron Forge | Build pipeline for Electron apps | per-project `forge.config.js` | None. |
| Laravel Forge CLI | Server provisioning client for Laravel SaaS | per-project + API tokens via login flow | None. |
| Autodesk Forge CLI | Autodesk Platform Services client | per-project, env vars | None. |
| AUR `foundry-bin` | Distribution channel for Foundry on Arch | same as Foundry | same as Foundry |
| AUR `forge-code-bin` | Distribution channel for ForgeCode on Arch | same as ForgeCode | same as ForgeCode |

### Consequences

- [+] Users with `git-pkgs/forge` installed can also use forge-cli without collisions. Each tool reads only files it owns.
- [+] Convention follows XDG; no special-snowflake path to document.
- [+] Future forge-cli XDG settings can land at `~/.config/forge/config.{toml,yaml}` without breaking existing artifacts.
- [-] Binary-name collision with Foundry persists on `$PATH`. Users running both must resolve via PATH ordering, an alias, or by renaming one of the binaries. This is outside the scope of the config convention.
- [-] git-pkgs/forge users may briefly wonder why two unrelated tools share the directory. Documented here so the answer exists.

## Related Decisions

- [UserConfig][UC] — establishes the per-artifact-file convention inside `~/.config/forge/`
- [ARCH-0008](ARCH-0008 Multi-Provider Support.md) — establishes how forge modules deploy across providers; the user-config convention complements deployment with a per-user-machine layer

## Links

- [forge-cli][FC] — this project
- [git-pkgs/forge][GP] — Git provider CLI, uses `~/.config/forge/config`
- [Foundry config reference][FD] — `~/.foundry/foundry.toml`
- [ForgeCode FORGE_CONFIG docs][AN] — `~/forge/.forge.toml`
- [Homebrew formula `forge` (ArrayFire)][HB]
- [Atlassian Forge CLI reference][AF]
- [XDG Base Directory Spec][XDG]

[UC]: ../../rules/UserConfig.md
[FC]: https://github.com/N4M3Z/forge-cli
[GP]: https://github.com/git-pkgs/forge
[FD]: https://github.com/foundry-rs/foundry/blob/master/crates/config/README.md
[AN]: https://forgecode.dev/docs/forge-config/
[HB]: https://formulae.brew.sh/formula/forge
[AF]: https://developer.atlassian.com/platform/forge/cli-reference/
[XDG]: https://specifications.freedesktop.org/basedir-spec/basedir-spec-latest.html
