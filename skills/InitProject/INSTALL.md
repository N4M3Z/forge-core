# Install InitProject

> Install the `project` and `atlas` shell functions (workshop scaffolding) and their config.

The skill ships both zsh functions next to this file. The functions are generic; all personal paths live in the config.

## OBJECTIVE

Make `project` and `atlas` available as autoloaded zsh functions reading `~/.config/forge/project.yaml`.

## DONE WHEN

`project list` prints `<owner>/<slug>` pairs under your workshop, and `project init /tmp/x` creates `/tmp/x` with `.git`, `.jj`, `.entire`, `private/`, `public/`, `.tlp`, and a `.claude/settings.json`.

## TODO

- [ ] Place `project` and `atlas` on your zsh `fpath` (one function per file, autoloaded)
- [ ] Create `~/.config/forge/project.yaml` with your paths
- [ ] Copy `CLAUDE.md.tmpl` (next to this file) to `~/.config/forge/CLAUDE.md.tmpl`
- [ ] Reload the shell (or `autoload -Uz project atlas`)
- [ ] Verify with `project list` and a throwaway `project init`

## Steps

1. **Install the functions.** Copy `project` and `atlas` (next to this file) into your autoloaded functions directory and ensure that directory is on `fpath`, e.g. in `~/.zshrc`:

   ```sh
   cp "$CLAUDE_PLUGIN_ROOT/skills/InitProject/"{project,atlas} "${XDG_CONFIG_HOME:-$HOME/.config}/zsh/functions/"
   # in ~/.zshrc, once:
   fpath=("${XDG_CONFIG_HOME:-$HOME/.config}/zsh/functions" $fpath)
   autoload -Uz "${XDG_CONFIG_HOME:-$HOME/.config}/zsh/functions"/*(N.:t)
   ```

2. **Create the config** at `~/.config/forge/project.yaml`:

   ```yaml
   workshop: ~/Agents
   owner: YOURNAME
   archive: ~/Agents/archive
   vault: ~/Atlas/Domains
   work: ~/Atlas/Work
   data: ~/Data
   developer: ~/Developer
   documents: ~/Documents
   defaults:
       domain: Technology
   mount: ~/Atlas
   exclude: [Assets, Archives, Templates, Templater]
   githooks: ~/path/to/forge-core/.githooks
   ```

   `workshop`/`owner` place projects at `<workshop>/<owner>/<slug>`; `vault`/`work`/`data` are the satellite roots; `developer`/`documents` name the consumed-clones and deliverables layers (default `~/Developer`, `~/Documents`); `defaults:` powers `--all` and the `atlas` shorthand; `mount`/`exclude` shape the scaffolded `.claude/settings.json`; `githooks` is the entire/forge hooks template. Every path key is overridable per-shell via `FORGE_*` env vars (`FORGE_WORKSHOP`, `FORGE_OWNER`, …). Requires `yq`; `jq`, `entire`, `gh`, `zed`, and `zoxide` are used when present.

3. **Install the brief template.** Copy `CLAUDE.md.tmpl` (next to this file) to `~/.config/forge/CLAUDE.md.tmpl` (`FORGE_CLAUDE_TEMPLATE` overrides the location). `project init` renders it — substituting `{{title}}`, `{{workshop}}`, `{{owner}}`, `{{archive}}`, `{{vault}}`, `{{mount}}`, `{{data}}`, `{{developer}}`, `{{documents}}` — into new projects' `CLAUDE.md`/`AGENTS.md`. Without it, a built-in brief is used.

4. **Reload**: open a new shell, or run `autoload -Uz project atlas`.

## EXECUTE NOW

Run steps 1–4, then confirm `project list` works and `project init /tmp/initproject-check` scaffolds the spine (`.git`, `.jj`, `private/`, `public/`, `.tlp`, `.claude/settings.json`, a rendered `CLAUDE.md`).
