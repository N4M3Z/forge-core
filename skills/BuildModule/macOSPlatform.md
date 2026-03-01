# macOS

## Prerequisites

- **Git**: macOS will prompt you to install developer tools -- say yes
- **Claude Code**: `brew install --cask claude-code` or `curl -fsSL https://claude.ai/install.sh | bash`
- **Rust** (Rust modules only): `brew install rustup && rustup-init` or `curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh`
- **Make**: included with Xcode Command Line Tools

## Build

```bash
git submodule update --init lib
make -C lib build
make install
make verify
```
