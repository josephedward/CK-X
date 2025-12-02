#!/usr/bin/env bash
set -euo pipefail
kubectl -n ckad-p2 get svc sun-srv -o name >/dev/null

