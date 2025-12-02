#!/usr/bin/env bash
set -euo pipefail
comps=$(kubectl -n ckad-q03 get job neb-new-job -o jsonpath='{.spec.completions}')
test "$comps" = "3"

