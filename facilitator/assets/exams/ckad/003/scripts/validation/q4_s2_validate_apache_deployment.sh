#!/usr/bin/env bash
set -euo pipefail
# Degraded validation: deployment exists with replicas=2
replicas=$(kubectl -n ckad-q04 get deploy internal-issue-report-apache -o jsonpath='{.spec.replicas}' 2>/dev/null || echo "")
test "$replicas" = "2"

