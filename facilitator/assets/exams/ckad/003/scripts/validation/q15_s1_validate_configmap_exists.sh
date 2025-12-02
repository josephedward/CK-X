#!/usr/bin/env bash
set -euo pipefail
kubectl -n ckad-q15 get configmap configmap-web-moon-html -o name >/dev/null

