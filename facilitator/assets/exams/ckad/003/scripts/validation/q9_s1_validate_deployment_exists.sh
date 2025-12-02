#!/usr/bin/env bash
set -euo pipefail
kubectl -n ckad-q09 get deploy holy-api -o name >/dev/null

