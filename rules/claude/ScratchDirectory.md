---
targets: [claude]
mode: append
---

Under the Bash sandbox, `mktemp`'s default location (`/var/folders/...` on macOS) and `/tmp/claude` are in the write-allowlist, so `mktemp` works without disabling the sandbox.
