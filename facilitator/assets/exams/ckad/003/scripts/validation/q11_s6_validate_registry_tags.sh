#!/usr/bin/env bash
set -euo pipefail

command -v curl >/dev/null 2>&1 || { echo "curl not found"; exit 1; }

# Check registry API for tags of sun-cipher repository
resp=$(curl -fsS http://localhost:5000/v2/sun-cipher/tags/list || true)
[ -n "$resp" ] || { echo "registry not reachable"; exit 1; }

echo "$resp" | grep -q 'v1-docker' || { echo "v1-docker tag not present in registry"; exit 1; }
echo "$resp" | grep -q 'v1-podman' || { echo "v1-podman tag not present in registry"; exit 1; }

exit 0

