# Windows

## Prerequisites

- **Git**: [Git for Windows](https://git-scm.com/downloads/win) -- keep all defaults during setup
- **Claude Code**: `winget install Anthropic.ClaudeCode` or from PowerShell: `irm https://claude.ai/install.ps1 | iex`
- **Rust** (Rust modules only): `winget install -e --id Rustlang.Rustup`
- **Make** (optional): `winget install -e --id ezwinports.make` -- or use WSL / Git Bash instead

## Build

Prefer WSL or Git Bash -- the Makefile uses POSIX shell syntax.

If staying in PowerShell:

```powershell
git submodule update --init lib
$env:PATH = "$env:USERPROFILE\.cargo\bin;$env:PATH"
cargo build --release --manifest-path lib/Cargo.toml

.\lib\target\release\install-skills.exe skills --provider claude --scope workspace
.\lib\target\release\install-skills.exe skills --provider codex --scope workspace
.\lib\target\release\install-skills.exe skills --provider opencode --scope workspace
```

Modules with agents also need:

```powershell
.\lib\target\release\install-agents.exe agents --scope workspace
```

## Notes

Claude Code runs natively on Windows 10 (1809+). WSL 2 also works and avoids most POSIX compatibility issues.
