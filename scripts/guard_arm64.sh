#!/usr/bin/env bash
set -euo pipefail

# Guard rails to prevent pulling/running AMD64 images on ARM64 hosts.
# Fails fast if CKX_PLATFORM is not linux/arm64 or if any service lacks a platform pin.

root_dir="$(cd "$(dirname "$0")/.." && pwd)"
compose_file="${COMPOSE_FILE:-docker-compose.yaml}"

# 1) Require CKX_PLATFORM=linux/arm64 in .env or environment
CKX_PLATFORM_VAL=${CKX_PLATFORM:-}
if [[ -z "$CKX_PLATFORM_VAL" ]]; then
  # Try to source from .env if present
  if [[ -f "$root_dir/.env" ]]; then
    # shellcheck disable=SC2046
    export $(grep -E '^[A-Za-z_][A-Za-z0-9_]*=' "$root_dir/.env" | xargs -0 -I {} echo {}) >/dev/null 2>&1 || true
    CKX_PLATFORM_VAL=${CKX_PLATFORM:-}
  fi
fi

if [[ "$CKX_PLATFORM_VAL" != "linux/arm64" ]]; then
  echo "[ARM64 GUARD] CKX_PLATFORM must be set to linux/arm64 to prevent amd64 pulls." >&2
  echo "[ARM64 GUARD] Set it in .env: CKX_PLATFORM=linux/arm64" >&2
  exit 2
fi

# 2) Ensure every service has platform: ${CKX_PLATFORM} pinned
cfg=$(docker compose -f "$root_dir/$compose_file" config 2>/dev/null || true)
if [[ -z "$cfg" ]]; then
  echo "[ARM64 GUARD] Unable to render compose config. Is Docker running?" >&2
  exit 2
fi

# Extract service names and ensure platform is present
missing=()
current_service=""
while IFS= read -r line; do
  if [[ $line =~ ^services: ]]; then
    continue
  fi
  if [[ $line =~ ^[[:space:]]{2}([a-zA-Z0-9_.-]+):[[:space:]]*$ ]]; then
    current_service="${BASH_REMATCH[1]}"
    have_platform=0
  elif [[ $line =~ ^[[:space:]]{4}platform:[[:space:]]+linux/arm64 ]]; then
    have_platform=1
  elif [[ $line =~ ^[[:space:]]{2}[a-zA-Z0-9_.-]+:[[:space:]]*$ ]]; then
    # Next top-level section; finalize previous service
    if [[ -n "$current_service" && ${have_platform:-0} -ne 1 ]]; then
      missing+=("$current_service")
    fi
    current_service=""
    have_platform=0
  fi
done <<<"$cfg"

# Finalize last service
if [[ -n "$current_service" && ${have_platform:-0} -ne 1 ]]; then
  missing+=("$current_service")
fi

if (( ${#missing[@]} > 0 )); then
  echo "[ARM64 GUARD] The following services are missing platform: linux/arm64:" >&2
  printf '  - %s\n' "${missing[@]}" >&2
  echo "Edit docker-compose.yaml to add: platform: \${CKX_PLATFORM} under each service." >&2
  exit 2
fi

echo "[ARM64 GUARD] OK: CKX_PLATFORM=linux/arm64 and all services are pinned."

