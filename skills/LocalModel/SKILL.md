---
name: LocalModel
version: 0.1.0
description: "Run prompts against a local LLM backend (LM Studio, Ollama, or MLX) with privacy-preserving output guardrails — drop reasoning_content, enforce structured output schemas, and post-redact identifiers. USE WHEN sending sensitive content to a model, classifying private data on-machine, scanning dotfiles or configs for leaks via local LLM, content audit that must not touch cloud APIs."
sources:
    - https://lmstudio.ai/docs/local-server
    - https://github.com/ollama/ollama/blob/main/docs/api.md
    - https://github.com/ml-explore/mlx-examples/tree/main/llms/mlx_lm
---

# LocalModel

Invoke a locally hosted LLM (LM Studio, Ollama, or MLX) with structured output and three layers of leak prevention. All three backends speak the OpenAI-compatible `POST /v1/chat/completions` interface; the skill provides a single wrapper that probes for whichever is running and applies the same safety rails to every backend.

The skill exists because **chain-of-thought reasoning models leak in `reasoning_content`** even when the prompt forbids reproducing values. Nemotron, DeepSeek-R1, QwQ, and similar models emit their working notes through a separate response field that is not subject to the same constraints as the final answer. Naive wrappers that fall back to `reasoning_content` when `content` is empty (e.g. when the token budget is exhausted mid-thought) print raw secrets directly to logs.

## Workflow Routing

| Trigger                                                                  | Companion / script                                         |
| ------------------------------------------------------------------------ | ---------------------------------------------------------- |
| User asks to scan, classify, or audit sensitive content via a local LLM  | [scripts/classify.py](scripts/classify.py)                 |
| User asks which local backend is running, or wants to probe availability | [scripts/detect-backend.sh](scripts/detect-backend.sh)     |
| User asks for raw inference (no privacy constraints)                     | Use `classify.py --no-redact --raw` flag                   |

## Backends

| Backend   | Default port | Auth                          | Endpoint                  |
| --------- | -----------: | ----------------------------- | ------------------------- |
| LM Studio |        1234  | Bearer token (`LMSTUDIO_API_KEY` in `.env`) | `/v1/chat/completions`    |
| Ollama    |       11434  | none                          | `/v1/chat/completions` (OpenAI-compat) or `/api/chat` (native) |
| MLX       |        8080  | none (default `mlx_lm.server`)| `/v1/chat/completions`    |

`scripts/detect-backend.sh` probes each port in that order and returns the first responding backend's identifier on stdout.

## Three layers of leak prevention

**Layer 1 — prompt-side classification, not reproduction.** The system prompt asks the model for *categories* + counts, never raw values. Output schema is enforced: a markdown table with `Category | Count | Risk`. Free-text answers are rejected by the wrapper.

**Layer 2 — drop `reasoning_content` entirely.** The wrapper reads only `choices[0].message.content`. If `content` is empty (token budget exhausted before the final answer emitted), the wrapper reports `[scan failed: model produced no final content]` and discards `reasoning_content` unread. Falling back to reasoning is forbidden because chain-of-thought emits raw values mid-thought regardless of prompt constraints.

**Layer 3 — post-redaction regex sweep on the model's output.** Even with the first two layers, the wrapper runs a final pass that masks:

- IPv4 literals: `\b\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}\b` → `<IP>`
- IPv6 literals: `\b([0-9a-fA-F]{1,4}:){2,7}[0-9a-fA-F]{1,4}\b` → `<IPV6>`
- Email-like: `\b[\w.+-]+@[\w-]+\.[\w.-]+\b` → `<EMAIL>`
- FQDN-like (any TLD ≥ 2 chars): `\b[a-z0-9][\w-]*\.[a-z]{2,}(?:\.[a-z]{2,})*\b` → `<HOST>`
- Short identifiers with at least one digit (a common machine-name pattern): `\b[a-z]{2,4}-?\d+[a-z0-9-]*\b` → `<ID>`. The leading-letter cap and required digit avoid over-matching English hyphenated words like `keep-private`.

## When NOT to use this skill

Structural audits (counting how many `Host`, `HostName`, `IdentityFile`, `ProxyJump` directives exist in an SSH config) are deterministic grep work. The LLM adds no signal and creates leak risk. Prefer:

```sh
for directive in Host HostName User Port IdentityFile ProxyJump ProxyCommand Match Include; do
    count=$(grep -ciE "^\s*${directive}\s" "$file")
    [ "$count" -gt 0 ] && printf "  %-16s  %s\n" "$directive" "$count"
done
```

The LLM earns its place when the question is semantic ("does this file expose infrastructure topology?", "is this comment hint a leak vector?") and the answer can be expressed as a category + count.

## Constraints

- **Never read `reasoning_content`** from the response. Treat it as if the field does not exist. If `content` is empty, the scan failed; do not patch with reasoning.
- **Never echo raw model output to chat** before running it through the Layer 3 redaction pass.
- **Always set a tight `max_tokens` budget** when the goal is a fixed-schema reply (e.g. 200 for a category table). High budgets give reasoning models more room to leak.
- **Reject free-text responses.** If the model output does not match the structured schema declared in the prompt, treat it as a failed scan and do not display the raw text.
- **Auth via env var, not flag.** `LMSTUDIO_API_KEY` reads from `~/.env` or the process environment. Never pass keys as positional arguments visible in `ps aux`.
- **Backend detection is deterministic.** `detect-backend.sh` probes ports in a fixed order (LM Studio 1234, Ollama 11434, MLX 8080) and stops at the first responder. No DNS, no env-var fallback that could be spoofed.
- **Tiny models may emit nothing useful.** Reasoning models with ≤ 8B parameters often spend the entire token budget on chain-of-thought and produce empty `content`. Prefer non-reasoning models (e.g. `qwen2.5-7b-instruct`, `gpt-oss-20b`) for classification tasks.
