Repo-local tooling activation — git `core.hooksPath`, the jj `push` alias, any hook-enable step — must be wired by a committed install step (a `make install` target, or the CLI's install command), never left as per-machine config set by hand or by a retrofit.

Machine-local config (`jj config --repo`, `git config`) does not travel with the repo. A fresh clone, another machine, a contributor, or CI gets the committed hook files but not the config that activates them, so the secret scan and other hooks silently fail to fire while still looking installed.

A retrofit script may set live config for the current machine, but it must also patch the committed installer so the wiring reproduces. Setting live config alone is the bug, not the fix.
