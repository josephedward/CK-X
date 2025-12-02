#!/usr/bin/env bash
set -euo pipefail

# Pass (skip) if helm is not available
if ! command -v helm >/dev/null 2>&1; then
  exit 0
fi

# Ensure the apiv1 release is no longer listed in ckad-q04
if helm list -n ckad-q04 2>/dev/null | awk '{print $1}' | grep -qx "internal-issue-report-apiv1"; then
  exit 1
fi
exit 0

