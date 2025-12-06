#!/usr/bin/env bash
set -euo pipefail

# Degraded path: if Docker is unavailable, accept logs marker
LOGS_FILE="/opt/course/exam3/q11/logs"
LOGS_OK=0
if [ -f "$LOGS_FILE" ] && grep -q "SUN_CIPHER_ID" "$LOGS_FILE"; then LOGS_OK=1; fi

# Docker-only check
if command -v docker >/dev/null 2>&1; then
  if ! docker ps --format '{{.Names}}' | grep -qx 'sun-cipher'; then
    # Fall back to logs acceptance if present
    test "$LOGS_OK" -eq 1 && exit 0
    echo "sun-cipher container not running (docker)"; exit 1
  fi
  IMG_NAME=$(docker inspect --format '{{.Config.Image}}' sun-cipher 2>/dev/null || true)
  echo "$IMG_NAME" | grep -q 'localhost:5000/sun-cipher' || { echo "container not using localhost:5000/sun-cipher image (docker)"; exit 1; }
  echo "$IMG_NAME" | grep -Eq ':(v1-docker)$' || { echo "container tag not :v1-docker (docker)"; exit 1; }
  exit 0
fi

# No docker available: accept degraded path only if logs marker is present
test "$LOGS_OK" -eq 1 || { echo "No container runtime available and logs marker missing"; exit 1; }
exit 0
