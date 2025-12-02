#!/usr/bin/env bash
set -euo pipefail
par=$(kubectl -n ckad-q03 get job neb-new-job -o jsonpath='{.spec.parallelism}')
test "$par" = "2"

