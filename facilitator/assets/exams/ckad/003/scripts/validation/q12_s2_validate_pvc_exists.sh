#!/usr/bin/env bash
set -euo pipefail
kubectl -n ckad-q12 get pvc earth-project-earthflower-pvc -o name >/dev/null

