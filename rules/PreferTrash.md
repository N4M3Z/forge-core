Delete user files with `trash` (macOS ships `/usr/bin/trash`), never `rm`. Trash moves items to the Finder Trash, so every deletion is recoverable and passes the destructive-command guards that rightly block `rm -rf` and relocate-then-delete `mv` chains on home paths.

`rm` remains fine for scratch and regenerable content only: `mktemp` dirs, `build/` output, caches (see ScratchDirectory). If the path wasn't created this session or isn't regenerable, it goes to the Trash, not oblivion.

`trash` is pre-approved (`permissions.allow` + `sandbox.excludedCommands`); prefer it as the first reach, not the fallback after a blocked `rm`.
