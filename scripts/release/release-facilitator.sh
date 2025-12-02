#!/usr/bin/env bash
set -euo pipefail

# Build and push the facilitator image (ARM64 only) with exam assets baked in.
# Usage:
#   REGISTRY=ghcr.io IMAGE_NS=your-org IMAGE_NAME=ckx-facilitator IMAGE_TAG=v0.1.0 \
#     scripts/release/release-facilitator.sh
#
# Requires:
#   - docker buildx (docker 20.10+)
#   - logged in to target registry (docker login ...)

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"/..
cd "$ROOT_DIR"

: "${REGISTRY:?Set REGISTRY (e.g., ghcr.io or docker.io)}"
: "${IMAGE_NS:?Set IMAGE_NS (e.g., your DockerHub or GHCR org)}"
IMAGE_NAME="${IMAGE_NAME:-ckx-simulator-facilitator}"
IMAGE_TAG="${IMAGE_TAG:-latest}"
PLATFORM="linux/arm64"
IMAGE_REF="${REGISTRY}/${IMAGE_NS}/${IMAGE_NAME}:${IMAGE_TAG}"

echo "[release] Building ${IMAGE_REF} for ${PLATFORM}..."

# Ensure buildx builder exists
docker buildx inspect ckx-builder >/dev/null 2>&1 || docker buildx create --name ckx-builder --use

docker buildx build \
  --platform "${PLATFORM}" \
  -t "${IMAGE_REF}" \
  --push \
  facilitator

cat <<EOF

[release] Pushed: ${IMAGE_REF}
[release] To use it locally, either:
  1) export CKX_FACILITATOR_IMAGE=${IMAGE_REF} && docker compose pull facilitator && docker compose up -d facilitator
  2) Add CKX_FACILITATOR_IMAGE=${IMAGE_REF} to .env and run: docker compose up -d

EOF

