---
name: InitProject
version: 0.2.0
description: "Scaffold a workshop project: a VCS spine (git + jj colocate + entire + forge hooks), the private/public/assets flow layout with a .tlp manifest, a .claude/ that mounts the knowledge vault, and on-demand satellites (vault folder-note, data dir, private remote). USE WHEN starting a new project, initializing a folder for work, adding a vault note or data dir or remote to a project, archiving a project, or the user runs `project` / `atlas`."
---

# InitProject

Turn a directory into a permanent **project spine** the rest of the workflow relies on: version control that survives (`claude --resume` keys off the cwd path), a `.claude/` wired to the knowledge vault, the flow layout, and a brief. The folder is the source of record — git, jj, entire, and sessions anchor to it; it is never scratch.

## The layout

Projects live at `<workshop>/<owner>/<slug>` (owner-mirror; `~/Agents/N4M3Z/zed`). Inside:

- `private/` — unpublished: immutable inputs and work in progress (TLP AMBER; pin RED per-project globs in `.tlp` for sensitive sources)
- `public/` — deliverables (GREEN)
- `assets/` — publishable media (GREEN)
- `docs/todos/` — dated backlog files
- `.tlp` — TLP manifest mapping levels to globs; `CLAUDE.md` / `AGENTS.md` — self-contained briefs (CLEAR)

Archive by moving: `project archive <slug>` → `<archive>/<owner>/<slug>`. Path is status.

## Do this

1. **Lay the spine through the shell function.**
   `! project create <slug>` — or the maximal one-liner `! project create <slug> --all` (vault note in the default Domain, data dir of the default Type, private GitHub remote). `! atlas <slug> <Domain>` is the vault-flavored shorthand. `! project init <dir>` scaffolds or retrofits an existing directory; every step is idempotent.
2. **Enrich, the part the shell can't do.** Fill `.claude/CLAUDE.md` with a real one-line brief (ask the user if unclear), mirror it into `AGENTS.md`, and seed type-specific `.claude/skills/` when the project type calls for it.
3. **Add satellites when the work needs them, not before.** `! project note [Domain]`, `! project data [Type]`, `! project remote` work from inside the project retroactively. `project data` also grants the created dir to the project's agent sessions (`additionalDirectories` in `.claude/settings.json`, via jq) — re-running it on an existing project is the retrofit for that grant.

## Config

All personal paths live in `~/.config/forge/project.yaml` (workshop root, owner, archive, vault/work/data satellite roots, `developer`/`documents` layer roots, `defaults:` for `--all`, vault mount + excludes, githooks template). Every path is overridable per-shell with a `FORGE_*` env var (`FORGE_WORKSHOP`, `FORGE_OWNER`, `FORGE_ARCHIVE`, `FORGE_VAULT`, `FORGE_WORK`, `FORGE_DATA`, `FORGE_MOUNT`, `FORGE_DEVELOPER`, `FORGE_DOCUMENTS`, `FORGE_GITHOOKS`, `FORGE_DOMAIN`) — env beats config beats built-in defaults. The function and this skill stay generic. Install via [@INSTALL.md](INSTALL.md). The functions ship alongside this skill (`project`, `atlas`), as does `CLAUDE.md.tmpl` — the scaffold brief template deployed to `~/.config/forge/CLAUDE.md.tmpl` (`FORGE_CLAUDE_TEMPLATE` overrides the path). `project init` renders it with the resolved roots ({{title}}, {{workshop}}, {{owner}}, {{archive}}, {{vault}}, {{mount}}, {{data}}, {{developer}}, {{documents}}) into `CLAUDE.md`/`AGENTS.md` when those files are absent; without the template it falls back to a built-in brief.

## Constraints

- The project folder is permanent. Keep it clean by **promoting keepers out** (knowledge → the vault, deliverables → `~/Documents`, data → `~/Data`), never by deleting it; deletion orphans the git/jj/entire history and Claude's resumable sessions.
- Never put a project's working folder **inside** the Obsidian vault — the vault gets the folder-note satellite, the churn stays in the workshop.
- jj does not run git hooks; the copied `.githooks` include the `jj-push` wrapper that keeps entire and gitleaks firing on push.
