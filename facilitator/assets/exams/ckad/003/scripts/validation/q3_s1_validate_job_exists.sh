#!/usr/bin/env bash
set -euo pipefail
kubectl -n ckad-q03 get job neb-new-job -o name >/dev/null

