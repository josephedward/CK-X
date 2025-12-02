#!/usr/bin/env bash
set -euo pipefail
rep=$(kubectl -n ckad-q09 get deploy holy-api -o jsonpath='{.spec.replicas}')
test "$rep" = "3"

