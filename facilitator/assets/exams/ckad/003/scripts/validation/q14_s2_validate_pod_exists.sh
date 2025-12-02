#!/usr/bin/env bash
set -euo pipefail
kubectl -n ckad-q14 get pod secret-handler -o name >/dev/null

