Always prefix shell commands with `rtk` — hard requirement, not optional. RTK calls binaries directly and bypasses aliases.

RTK does not support `-C <dir>` — use `command git -C <dir>` or absolute paths for submodule git operations.
