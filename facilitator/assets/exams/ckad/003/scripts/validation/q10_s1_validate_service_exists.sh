#!/usr/bin/env bash
set -euo pipefail
kubectl -n ckad-q10 get svc project-plt-6cc-svc -o name >/dev/null

