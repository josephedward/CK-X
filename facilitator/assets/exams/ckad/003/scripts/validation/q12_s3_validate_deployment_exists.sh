#!/usr/bin/env bash
set -euo pipefail
kubectl -n ckad-q12 get deploy project-earthflower -o name >/dev/null

