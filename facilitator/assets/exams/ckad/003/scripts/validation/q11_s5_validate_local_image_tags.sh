#!/usr/bin/env bash
set -euo pipefail

# Degraded path policy: pass if docker tag exists; if no docker, pass if logs marker exists
LOGS_FILE="/opt/course/exam3/q11/logs"
LOGS_OK=0
if [ -f "$LOGS_FILE" ] && grep -q "SUN_CIPHER_ID" "$LOGS_FILE"; then LOGS_OK=1; fi

found=0

# Check docker image tag exists
if command -v docker >/dev/null 2>&1; then
  if docker images --format '{{.Repository}}:{{.Tag}}' | grep -q '^localhost:5000/sun-cipher:v1-docker$'; then
    found=1
  fi
fi

# If docker tag not found, allow logs-only degraded path
if [ "$found" -ne 1 ]; then
  test "$LOGS_OK" -eq 1 || { echo "no local tags found and no logs marker"; exit 1; }
fi

exit 0
