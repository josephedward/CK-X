#!/usr/bin/env bash
set -euo pipefail

# CK-X Exam 3 launcher (single script)
# Usage:
#   bash scripts/exam3.sh           # Fresh start (project-only)
#   bash scripts/exam3.sh --full    # Full system nuke (ALL containers/images/volumes), then start

ROOT_DIR=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)
cd "$ROOT_DIR"

mode="project"
if [[ "${1:-}" == "--full" ]]; then
  mode="full"
fi

ensure_env() {
  if [[ ! -f .env ]]; then
    cat > .env <<EOF
CKX_IMAGE_NS=je01
CKX_VERSION=exam3-v2
EOF
    echo "Created .env with CKX_IMAGE_NS=je01, CKX_VERSION=exam3-v2"
  else
    echo ".env present; using CKX_IMAGE_NS/CKX_VERSION"
  fi
}

arm64_check() { :; }

if [[ "$mode" == "full" ]]; then
  echo "[1/5] FULL NUKE: Removing ALL containers/images/volumes/networks"
  docker ps -aq | xargs -r docker rm -f || true
  docker images -q | xargs -r docker rmi -f || true
  docker volume ls -q | xargs -r docker volume rm -f || true
  docker network prune -f || true
  ensure_env
  echo "[2/5] Pull images"
  docker compose pull
  arm64_check
  echo "[3/5] Start"
  docker compose up -d
  echo "[4/5] Stack running"
  echo "[5/5] Open http://localhost:30080 → Start Exam → CKAD Comprehensive Lab - 3"
  exit 0
fi

echo "[1/4] Down + remove volumes (project-only)"
docker compose down -v --remove-orphans || true

echo "[2/4] Remove images referenced by compose (force fresh pull)"
IMAGES=$(docker compose config | awk '/image:/ {print $2}' | sort -u || true)
if [[ -n "${IMAGES}" ]]; then
  while read -r img; do
    [[ -z "$img" ]] && continue
    echo "  - removing $img"
    docker image rm -f "$img" >/dev/null 2>&1 || true
  done <<< "$IMAGES"
else
  echo "  (no explicit images found)"
fi

ensure_env

# Also remove legacy 'course-data' project volume if present (was used by older configs)
VOL=$(docker volume ls -q | grep -E 'course-data$' || true)
if [[ -n "$VOL" ]]; then
  echo "[cleanup] Removing legacy course-data volume(s)"
  echo "$VOL" | xargs -r docker volume rm -f || true
fi

echo "[3/4] Pull images"
docker compose pull
arm64_check

echo "[4/4] Start"
docker compose up -d

echo
echo "Fresh stack is up. Open: http://localhost:30080 → Start Exam → CKAD Comprehensive Lab - 3"
