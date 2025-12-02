#!/usr/bin/env bash
set -euo pipefail

# Build and push CK-X images for exam-003 (Apple Silicon, single tag)
#
# Usage:
#   # simplest: read NS/TAG from .env (CKX_IMAGE_NS/CKX_VERSION)
#   bash scripts/build_and_push.sh
#
#   # or provide env vars explicitly
#   CKX_IMAGE_NS=myuser CKX_VERSION=exam3-local bash scripts/build_and_push.sh
#
# Images (single-arch):
#   - $NS/ckx-remote-desktop:$TAG  (./remote-desktop)
#   - $NS/ckx-webapp:$TAG          (./app)
#   - $NS/ckx-nginx:$TAG           (./nginx)
#   - $NS/ckx-jumphost:$TAG        (./jumphost)
#   - $NS/ckx-cluster:$TAG         (./kind-cluster)
#   - $NS/ckx-facilitator:$TAG     (./facilitator)

ROOT_DIR=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)
cd "$ROOT_DIR"

# Load NS/TAG
NS=${CKX_IMAGE_NS:-}
TAG=${CKX_VERSION:-}

if [[ -z "${NS}" || -z "${TAG}" ]]; then
  if [[ -f .env ]]; then
    # shellcheck disable=SC2046
    export $(grep -E '^(CKX_IMAGE_NS|CKX_VERSION)=' .env | xargs -I{} echo {})
    NS=${CKX_IMAGE_NS:-${NS:-}}
    TAG=${CKX_VERSION:-${TAG:-}}
  fi
fi

if [[ -z "${NS}" || -z "${TAG}" ]]; then
  echo "Set CKX_IMAGE_NS and CKX_VERSION (in .env or as env vars)." >&2
  echo "Example: CKX_IMAGE_NS=myuser CKX_VERSION=exam3-local bash scripts/build_and_push.sh" >&2
  exit 1
fi

echo "Building single-arch images for Apple Silicon (arm64 host)"
echo "Namespace: $NS"
echo "Tag      : $TAG"

# Facilitator uses npm ci -> ensure a lockfile exists to avoid build failure
if [[ ! -f facilitator/package-lock.json ]]; then
  echo "[facilitator] package-lock.json not found; generating (npm install --package-lock-only)"
  (cd facilitator && npm install --package-lock-only >/dev/null)
fi

build_push() {
  local name="$1" path="$2"
  local image="$NS/ckx-$name:$TAG"
  echo "\n==> Building $image from $path"
  docker build -t "$image" "$path"
  echo "Pushing $image"
  docker push "$image"
}

# Build + push in deterministic order
build_push remote-desktop ./remote-desktop
build_push webapp          ./app
build_push nginx           ./nginx
build_push jumphost        ./jumphost
build_push cluster         ./kind-cluster
build_push facilitator     ./facilitator

echo "\nAll images pushed under: $NS (tag: $TAG)"
echo "Update .env if needed:"
echo "  CKX_IMAGE_NS=$NS"
echo "  CKX_VERSION=$TAG"
echo "Then start fresh: bash scripts/exam3.sh"

