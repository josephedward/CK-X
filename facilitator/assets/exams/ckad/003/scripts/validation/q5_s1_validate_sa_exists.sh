#!/usr/bin/env bash
set -euo pipefail
kubectl -n service-accounts get sa neptune-sa-v2 -o name >/dev/null