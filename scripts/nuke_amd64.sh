#!/usr/bin/env bash
set -euo pipefail

# Remove all containers/images that are AMD64 for CK-X services, with prejudice.
# Optionally pass an image digest to purge first, e.g.:
#   bash scripts/nuke_amd64.sh sha256:d5ef565bc10ab554c6b38076c36881e28e9c21c3e1ba37f36f48da910b4d2ca5

DIGEST_TO_PURGE="${1:-}"

echo "[NUKE] Stopping stack (if running)"
if command -v docker >/dev/null 2>&1; then
  docker compose down -v --remove-orphans >/dev/null 2>&1 || true
fi

if [[ -n "$DIGEST_TO_PURGE" ]]; then
  echo "[NUKE] Purging specific digest: $DIGEST_TO_PURGE"
  # Kill containers from the digest
  mapfile -t cids < <(docker ps -aq --filter ancestor="$DIGEST_TO_PURGE" || true)
  if (( ${#cids[@]} )); then
    docker rm -f "${cids[@]}" || true
  fi
  # Remove the image by digest/id
  docker rmi -f "$DIGEST_TO_PURGE" || true
fi

echo "[NUKE] Scanning CK-X images for amd64"
mapfile -t imgs < <(docker images --format '{{.Repository}}:{{.Tag}}' | grep -E '(^|/)ckx-|(^|/)je01/ckx-|^redis:|^nginx:' || true)

purged=0
for ref in "${imgs[@]}"; do
  [[ -z "$ref" || "$ref" == *"<none>"* ]] && continue
  arch=$(docker image inspect --format '{{.Architecture}}' "$ref" 2>/dev/null || echo "unknown")
  if [[ "$arch" == "amd64" ]]; then
    echo "[NUKE] Removing amd64 image: $ref"
    # Remove any containers using it
    mapfile -t cids < <(docker ps -aq --filter ancestor="$ref" || true)
    if (( ${#cids[@]} )); then
      docker rm -f "${cids[@]}" || true
    fi
    # Remove the image
    docker rmi -f "$ref" || true
    purged=$((purged+1))
  fi
done

echo "[NUKE] Purged $purged amd64 images (if any). Pruning builder cache."
docker buildx prune -af >/dev/null 2>&1 || true

echo "[NUKE] Verification of running containers (should be none with amd64)"
docker ps -aq | while read -r cid; do
  img=$(docker inspect -f '{{.Image}}' "$cid" 2>/dev/null || true)
  [[ -z "$img" ]] && continue
  arch=$(docker image inspect -f '{{.Architecture}}' "$img" 2>/dev/null || echo "unknown")
  if [[ "$arch" == "amd64" ]]; then
    echo "[WARN] Container $cid still uses amd64 ($img). Removing."
    docker rm -f "$cid" || true
  fi
done

echo "[NUKE] Done. To re-pull ARM64 only, ensure CKX_PLATFORM=linux/arm64 and run:"
echo "       docker compose pull && docker compose up -d"

