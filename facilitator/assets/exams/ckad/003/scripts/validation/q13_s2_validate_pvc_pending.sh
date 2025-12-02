#!/usr/bin/env bash
set -euo pipefail
phase=$(kubectl -n ckad-q13 get pvc moon-pvc-126 -o jsonpath='{.status.phase}' 2>/dev/null || echo "")
test "$phase" = "Pending"

