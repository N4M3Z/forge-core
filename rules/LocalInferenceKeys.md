Local inference servers (oMLX on `127.0.0.1:8000`, LM Studio on `127.0.0.1:1234`) authenticate with an API key the user owns.

Read those keys from the environment, `OMLX_API_KEY` and `LMSTUDIO_API_KEY`, which live in `~/.env`. If not already exported, source it first: `set -a; . ~/.env; set +a`. Send the key only as the request `Authorization: Bearer <key>` header.

Never pass `--api-key` to `omlx serve` or `omlx start`, and never edit `~/.omlx/settings.json`: both persist the value and silently overwrite the user's key, which loses it. A 401 means the running server holds a different key, so read the key from `~/.env` or ask the user; do not reset it by relaunching with a new `--api-key`. Never kill or relaunch the user's managed oMLX server (`omlx start` / launchd `homebrew.mxcl.omlx`) to change auth or free a port; start a separate `omlx serve` on another port for scratch work and leave the managed server alone.

oMLX serves MLX/safetensors models only (`config.json` + `*.safetensors`), not GGUF; a GGUF-only download (for example from LM Studio) needs a separate MLX build. When inlining file contents into a model prompt from zsh, iterate an array (`files=(a b c); for f in $files`), not a space-joined string: zsh does not word-split an unquoted scalar, so `for f in "$string"` runs once over the whole value and the reads fail. Use `command cat` to bypass any rtk alias.
