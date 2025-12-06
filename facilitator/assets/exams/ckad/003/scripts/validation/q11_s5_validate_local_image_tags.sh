#!/usr/bin/env bash
set -euo pipefail

ok=0

# Check docker image tag exists
if command -v docker >/dev/null 2>&1; then
  if docker images --format '{{.Repository}}:{{.Tag}}' | grep -q '^localhost:5000/sun-cipher:v1-docker$'; then
    ok=$((ok+1))
  else
    echo "docker image tag localhost:5000/sun-cipher:v1-docker not found" >&2
  fi
else
  echo "docker not found" >&2
fi

# Check podman image tag exists
if command -v podman >/dev/null 2>&1; then
  if podman images --format '{{.Repository}}:{{.Tag}}' | grep -q '^localhost:5000/sun-cipher:v1-podman$'; then
    ok=$((ok+1))
  else
    echo "podman image tag localhost:5000/sun-cipher:v1-podman not found" >&2
  fi
else
  echo "podman not found" >&2
fi

# Require both tags to be present
test "$ok" -eq 2

