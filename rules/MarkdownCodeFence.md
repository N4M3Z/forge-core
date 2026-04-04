---
name: MarkdownCodeFence
version: 0.1.0
description: "Always specify language in fenced code blocks — ```sh for shell, ```rust for Rust, ```yaml for YAML."
targets: claude, gemini, codex, opencode
---

Every fenced code block must have a language identifier. Never use bare ` ``` ` without a language tag.

Common tags: `sh` (shell/bash), `rust`, `yaml`, `toml`, `json`, `python`, `typescript`, `sql`, `markdown`.

Use `sh` for shell commands, not `bash` — `sh` is the POSIX-portable tag.
