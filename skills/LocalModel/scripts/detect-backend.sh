#!/usr/bin/env bash
# Probe local LLM backends in deterministic order. Print the first responder's
# identifier ("lmstudio" | "ollama" | "mlx") to stdout, exit 0. If none respond,
# print "none" and exit 2.
#
# Usage: detect-backend.sh
#
# Authentication: LM Studio requires a Bearer token. The probe sends without
# auth and accepts HTTP 401 as a "backend reachable" signal (the auth check
# itself proves the server is up). Ollama and MLX accept no-auth probes.

set -u

probe() {
    local name="$1" url="$2"
    local code
    code=$(curl -sSo /dev/null -w '%{http_code}' --max-time 2 "$url" 2>/dev/null || echo "000")
    case "$code" in
        # 200: model list returned; 401: auth required, server up (LM Studio);
        # 404: endpoint exists at a different path but server up (some Ollama versions).
        200|401|404) echo "$name"; return 0 ;;
        *) return 1 ;;
    esac
}

probe lmstudio "http://localhost:1234/v1/models" && exit 0
probe ollama   "http://localhost:11434/v1/models" && exit 0
probe mlx      "http://localhost:8080/v1/models"  && exit 0

echo "none"
exit 2
