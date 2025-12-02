#!/usr/bin/env bash
set -euo pipefail

# Pass (skip) if helm is not available
if ! command -v helm >/dev/null 2>&1; then
  exit 0
fi

# Ensure there are no releases stuck in pending-install across namespaces
if helm ls -A 2>/dev/null | awk 'NR>1 {print tolower($8)}' | grep -q "pending-install"; then
  exit 1
fi
exit 0

