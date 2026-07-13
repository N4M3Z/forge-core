Forge artifacts that need per-user runtime data read from `~/.config/forge/<artifact>.{ext}` — one file per artifact, name matches the artifact (`forensic.yaml` for ForensicAgent, `avatar.yaml` for an avatar skill, `safety-net` for a flat-list hook). Each artifact picks the format that fits its tooling: YAML for shell + yq, TOML for Rust binaries, plain regex list for grep hooks.

Files live in the user's private dotfiles repo and deploy to `~/.config/forge/`. No artifact in a public forge module may hardcode a value that belongs in its config — names, emails, phones, hostnames, locale-specific identifiers all move out to the artifact's config file. The artifact source documents its expected schema; the values stay private.

Reserve `config*` at the root of `~/.config/forge/` for forge-cli's own future XDG settings — never name an artifact `config`. See [NAME-0001](../docs/decisions/NAME-0001%20Forge%20Naming%20Collisions.md) for the namespace landscape.
