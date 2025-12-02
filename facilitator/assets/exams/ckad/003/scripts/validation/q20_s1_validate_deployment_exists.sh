#!/usr/bin/env bash
set -euo pipefail
kubectl -n ckad-p1 get deploy project-23-api -o name >/dev/null

