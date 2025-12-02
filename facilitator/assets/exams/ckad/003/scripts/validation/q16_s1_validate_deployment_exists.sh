#!/usr/bin/env bash
set -euo pipefail
kubectl -n ckad-q16 get deploy cleaner -o name >/dev/null

