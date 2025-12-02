#!/usr/bin/env bash
set -euo pipefail
kubectl -n ckad-q02 get pod pod1 -o name >/dev/null

