#!/usr/bin/env bash
set -euo pipefail
DOCKERFILE="/opt/course/exam3/q11/image/Dockerfile"
test -f "$DOCKERFILE" || { echo "Dockerfile missing"; exit 1; }
grep -qE '^ENV[[:space:]]+SUN_CIPHER_ID=5b9c1065-e39d-4a43-a04a-e59bcea3e03f$' "$DOCKERFILE" || {
  echo "SUN_CIPHER_ID not hardcoded in Dockerfile"; exit 1;
}
exit 0

