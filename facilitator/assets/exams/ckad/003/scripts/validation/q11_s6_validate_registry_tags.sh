#!/usr/bin/env bash
set -euo pipefail

# Degraded path policy: if registry not reachable, accept logs marker instead
LOGS_FILE="/opt/course/exam3/q11/logs"
if [ -f "$LOGS_FILE" ] && grep -q "SUN_CIPHER_ID" "$LOGS_FILE"; then LOGS_OK=1; else LOGS_OK=0; fi

if ! command -v curl >/dev/null 2>&1; then
  # No curl: allow degraded path
  test "$LOGS_OK" -eq 1 || { echo "curl not found and no logs marker"; exit 1; }
  exit 0
fi

# Check registry API for tags of sun-cipher repository (best-effort)
resp=$(curl -fsS http://localhost:5000/v2/sun-cipher/tags/list || true)
if [ -z "$resp" ]; then
  # Registry unreachable: allow degraded path
  test "$LOGS_OK" -eq 1 || { echo "registry not reachable and no logs marker"; exit 1; }
  exit 0
fi

# Pass only if the docker tag is present
echo "$resp" | grep -Eq 'v1-docker' || { echo "expected docker tag not present in registry"; exit 1; }
exit 0
