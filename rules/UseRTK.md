Always prefix shell commands with `rtk` (where rtk stands for **Rust Token Killer**: <https://github.com/rtk-ai/rtk>) — hard requirement, not optional. RTK calls binaries directly and bypasses aliases.

RTK does not support `-C <dir>` — use `command git -C <dir>` or absolute paths for submodule git operations.
