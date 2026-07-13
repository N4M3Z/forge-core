# User Config Schema (autoMode mirror)

When an artifact needs per-user runtime data, follow the [UserConfig](../../rules/UserConfig.md) rule — one file per artifact at `~/.config/forge/<artifact>.{ext}`. When the config is intended to be read by an AI in the loop (skill, agent, or hook with model access), shape it after [Claude Code's `autoMode`][AM]: natural-language entries with a four-tier precedence model and a `$defaults` splice token.

## Why mirror autoMode

The pattern is already familiar to anyone configuring Claude Code. Entries are prose — descriptions a human (or AI) would naturally write — not regex or tool-pattern grammars. The `$defaults` token gives a splice-or-replace toggle for built-in defaults shipped with the artifact source. Users extend the built-ins by adding entries; they take full ownership by omitting `"$defaults"`.

## Shape

Top-level keys are tiers with strict precedence: `hard_deny` > `soft_deny` > `allow` > `environment`. Each value is an array of prose strings.

```yaml
environment:
    - "$defaults"
    - "<who I am and where I work>"

allow:
    - "$defaults"
    - "<exceptions to soft_deny — surfaces that are intentional>"

soft_deny:
    - "$defaults"
    - "<rules the user can override with explicit intent>"

hard_deny:
    - "$defaults"
    - "<rules that cannot be overridden>"
```

## Tier semantics

- `hard_deny` blocks unconditionally. No `allow` exception or user intent applies.
- `soft_deny` blocks next. `allow` exceptions and explicit user intent can override.
- `allow` overrides matching `soft_deny` entries.
- `environment` provides context: trusted infrastructure, identities, repo ownership.

Setting any tier without `"$defaults"` replaces the entire built-in list for that tier. Default entries are spliced at the position of the token, so custom entries can go before or after them.

## When NOT to use this pattern

Deterministic consumers (shell scripts, pre-commit hooks, CI gates without model access) can't interpret prose. Ship a sibling artifact for those — same `~/.config/forge/` directory, different filename — with a flat regex list or other machine-readable structure. Don't try to mix prose and regex in one file; the consumer types diverge.

Example pairing: `~/.config/forge/forensic.yaml` (prose, read by ForensicAgent) and `~/.config/forge/danger-strings` (regex, read by the pre-commit hook).

## Discovery and inspection

The artifact source documents its built-in `$defaults` inline (in `SKILL.md` body or the agent body) so users can read what they inherit before extending. A `forge <artifact> config` subcommand printing the effective merged config is recommended but not required.

## Reference

[AM]: https://code.claude.com/docs/en/auto-mode-config "Claude Code: Configure auto mode"
