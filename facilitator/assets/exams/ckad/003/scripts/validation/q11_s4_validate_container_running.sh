#!/usr/bin/env bash
set -euo pipefail

# Ensure podman is available
command -v podman >/dev/null 2>&1 || { echo "podman not found"; exit 1; }

# Check container is running and named correctly
if ! podman ps --format '{{.Names}}' | grep -qx 'sun-cipher'; then
  echo "sun-cipher container not running"; exit 1
fi

# Verify image reference contains the expected repo and tag
# Prefer ImageName, fall back to parsing from Image + image list
IMG_NAME=$(podman inspect --format '{{.ImageName}}' sun-cipher 2>/dev/null || true)
if [ -z "$IMG_NAME" ]; then
  # Older podman may not expose ImageName on containers; try image ID to name mapping
  IMG_ID=$(podman inspect --format '{{.Image}}' sun-cipher 2>/dev/null || true)
  if [ -n "$IMG_ID" ]; then
    IMG_NAME=$(podman images --format '{{.Repository}}:{{.Tag}} {{.ID}}' | awk -v id="$IMG_ID" '$2==id{print $1; exit}')
  fi
fi

echo "$IMG_NAME" | grep -q 'localhost:5000/sun-cipher' || { echo "container not using localhost:5000/sun-cipher image"; exit 1; }
echo "$IMG_NAME" | grep -q ':v1-podman' || { echo "container not using :v1-podman tag"; exit 1; }

exit 0

