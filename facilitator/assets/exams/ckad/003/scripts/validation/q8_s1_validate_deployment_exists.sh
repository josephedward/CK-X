#!/usr/bin/env bash
set -euo pipefail
kubectl -n ckad-q08 get deploy api-new-c32 -o name >/dev/null

