#!/usr/bin/env bash
set -euo pipefail
name=$(kubectl -n ckad-q02 get pod pod1 -o jsonpath='{.spec.containers[0].name}')
test "$name" = "pod1-container"

