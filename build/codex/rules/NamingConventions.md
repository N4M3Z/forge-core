Use **directories** not "folders" — in docs, commit messages, and conversation. Directories are semantic routing, not passive containers.

Scripts and binaries use kebab-case (`weather-stats`, `safe-read`, `build-templates`). Skill directories use PascalCase, but the executables inside them follow Unix convention.

File naming preference: use `Nice Naming.txt` (spaces, capitalized) when the filesystem and tooling support it (documentation, ADRs, Obsidian notes). When spaces cause problems (scripts, data files, CI paths, URLs), fall back to kebab-case (`account-classes.tsv`, `integration-spine.tsv`).

Never use snake_case or camelCase for non-code files.