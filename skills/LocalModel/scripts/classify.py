#!/usr/bin/env python3
"""Send a file or stdin to a local LLM for classification with three layers
of leak prevention. See sibling SKILL.md for the safety rationale.

Layer 1: prompt-side schema (categories + counts only, never raw values)
Layer 2: drop reasoning_content; if content is empty, report failed scan
Layer 3: regex post-redaction on the model's output

Usage:
    classify.py <file>                        # default classification prompt
    classify.py --prompt PROMPT <file>        # custom system prompt
    classify.py --model MODEL <file>          # override auto-selected model
    classify.py --backend lmstudio|ollama|mlx <file>   # override auto-detect
    classify.py --raw <file>                  # skip Layer 3 redaction (caller asserts the prompt is safe)
    cat file | classify.py                    # read from stdin
"""

import argparse
import json
import os
import pathlib
import re
import subprocess
import sys
import urllib.request
import urllib.error


BACKENDS = {
    "lmstudio": {"url": "http://localhost:1234/v1/chat/completions", "auth_env": "LMSTUDIO_API_KEY"},
    "ollama":   {"url": "http://localhost:11434/v1/chat/completions", "auth_env": None},
    "mlx":      {"url": "http://localhost:8080/v1/chat/completions",  "auth_env": None},
}


DEFAULT_SYSTEM = """You are a security auditor. Given a file fragment, enumerate the CATEGORIES of sensitive identifiers it contains.

Output rules (MANDATORY):
- Reply with ONLY a markdown table. No prose before or after.
- Columns: Category | Count | Risk (low|medium|high)
- NEVER echo any raw values: no hostnames, no IPs, no usernames, no port numbers, no key fingerprints, no path fragments, no comments.
- Categories to look for: Host aliases, HostName values, IP addresses, User identifiers, Port numbers, IdentityFile paths, ProxyJump targets, custom commands, comments hinting at topology.
- Add one final row: `Recommendation | <keep-private|publish-with-mask|encrypt-only> | n/a`.
"""


def load_env_var(name: str) -> str | None:
    """Read VAR from process env, falling back to ~/.env."""
    val = os.environ.get(name)
    if val:
        return val
    env_path = pathlib.Path.home() / ".env"
    if not env_path.exists():
        return None
    for line in env_path.read_text().splitlines():
        line = line.strip()
        if line.startswith(f"{name}="):
            return line.split("=", 1)[1].strip().strip('"').strip("'")
    return None


def detect_backend() -> str:
    """Run the sibling detect-backend.sh and return its stdout."""
    script = pathlib.Path(__file__).parent / "detect-backend.sh"
    result = subprocess.run([str(script)], capture_output=True, text=True)
    if result.returncode != 0:
        sys.exit("no local backend responding (LM Studio:1234, Ollama:11434, MLX:8080 all down)")
    return result.stdout.strip()


def pick_model(backend: str) -> str:
    """Return a sensible default model for the backend by querying its /v1/models."""
    base = BACKENDS[backend]["url"].rsplit("/chat/completions", 1)[0] + "/models"
    headers = {}
    if BACKENDS[backend]["auth_env"]:
        key = load_env_var(BACKENDS[backend]["auth_env"])
        if key:
            headers["Authorization"] = f"Bearer {key}"
    req = urllib.request.Request(base, headers=headers)
    try:
        with urllib.request.urlopen(req, timeout=5) as resp:
            body = json.loads(resp.read())
    except urllib.error.URLError as exc:
        sys.exit(f"failed to query {base}: {exc}")
    models = [m["id"] for m in body.get("data", [])]
    if not models:
        sys.exit(f"backend {backend} reports no loaded models")
    # Prefer non-reasoning models for classification (reasoning models leak in CoT).
    # Heuristic: ids containing 'instruct', 'chat', or 'gpt-oss' first.
    for keyword in ("instruct", "chat", "gpt-oss"):
        for m in models:
            if keyword in m.lower():
                return m
    return models[0]


def call_model(backend: str, model: str, system: str, user: str, max_tokens: int = 400) -> str:
    """POST to the backend's chat completions endpoint. Return content only —
    NEVER reasoning_content, per Layer 2 of the leak-prevention design."""
    payload = {
        "model": model,
        "messages": [
            {"role": "system", "content": system},
            {"role": "user", "content": user},
        ],
        "temperature": 0,
        "max_tokens": max_tokens,
    }
    headers = {"Content-Type": "application/json"}
    if BACKENDS[backend]["auth_env"]:
        key = load_env_var(BACKENDS[backend]["auth_env"])
        if key:
            headers["Authorization"] = f"Bearer {key}"
    req = urllib.request.Request(
        BACKENDS[backend]["url"],
        data=json.dumps(payload).encode(),
        headers=headers,
    )
    try:
        with urllib.request.urlopen(req, timeout=300) as resp:
            body = json.loads(resp.read())
    except urllib.error.HTTPError as exc:
        detail = exc.read().decode(errors="replace")[:500]
        sys.exit(f"backend returned {exc.code}: {detail}")
    except urllib.error.URLError as exc:
        sys.exit(f"backend unreachable: {exc}")
    msg = body["choices"][0]["message"]
    content = msg.get("content") or ""
    # Layer 2: do NOT fall back to reasoning_content. If content is empty,
    # the scan failed and reasoning is discarded unread.
    if not content.strip():
        return "[scan failed: model produced no final content; reasoning_content discarded unread]"
    return content


REDACT_PATTERNS = [
    (re.compile(r"\b\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}\b"), "<IP>"),
    (re.compile(r"\b(?:[0-9a-fA-F]{1,4}:){2,7}[0-9a-fA-F]{1,4}\b"), "<IPV6>"),
    (re.compile(r"\b[\w.+-]+@[\w-]+\.[\w.-]+\b"), "<EMAIL>"),
    # FQDN: at least one dot, lowercase TLD ≥ 2 chars
    (re.compile(r"\b[a-z0-9][\w-]*\.[a-z]{2,}(?:\.[a-z]{2,})*\b", re.IGNORECASE), "<HOST>"),
    # Short machine-name pattern: 2-4 lowercase letters, optional hyphen, then
    # at least one digit (so hyphenated English words like "keep-private" do
    # not over-match).
    (re.compile(r"\b[a-z]{2,4}-?\d+[a-z0-9-]*\b"), "<ID>"),
]


def redact(text: str) -> str:
    """Layer 3: mask anything that looks like a leaked identifier."""
    for pattern, replacement in REDACT_PATTERNS:
        text = pattern.sub(replacement, text)
    return text


def main():
    parser = argparse.ArgumentParser(description="Local-LLM classifier with leak prevention")
    parser.add_argument("file", nargs="?", help="file to classify (omit to read stdin)")
    parser.add_argument("--prompt", help="custom system prompt (default: schema-based categorization)")
    parser.add_argument("--backend", choices=list(BACKENDS), help="force a backend (default: auto-detect)")
    parser.add_argument("--model", help="override model id (default: backend's first non-reasoning model)")
    parser.add_argument("--max-tokens", type=int, default=400)
    parser.add_argument("--raw", action="store_true", help="skip Layer 3 redaction (caller asserts safety)")
    args = parser.parse_args()

    if args.file:
        content = pathlib.Path(args.file).read_text()
        filename = pathlib.Path(args.file).name
    else:
        content = sys.stdin.read()
        filename = "<stdin>"

    backend = args.backend or detect_backend()
    model = args.model or pick_model(backend)
    system = args.prompt or DEFAULT_SYSTEM

    reply = call_model(
        backend=backend,
        model=model,
        system=system,
        user=f"File: {filename}\n\n```\n{content}\n```",
        max_tokens=args.max_tokens,
    )
    if not args.raw:
        reply = redact(reply)

    print(f"backend: {backend}")
    print(f"model:   {model}")
    print()
    print(reply)


if __name__ == "__main__":
    main()
