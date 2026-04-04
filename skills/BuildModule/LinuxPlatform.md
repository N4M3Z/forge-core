# Linux

## Prerequisites

- **Git**: install using your favourite package manager (`apt install git`, `dnf install git`, `pacman -S git`)
- **Claude Code**: `curl -fsSL https://claude.ai/install.sh | bash`
- **Rust** (Rust modules only): `curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh`
- **Make**: install using your favourite package manager (`apt install make`, `dnf install make`)

## Build

```bash
git submodule update --init lib
make -C lib build
make install
make verify
```
