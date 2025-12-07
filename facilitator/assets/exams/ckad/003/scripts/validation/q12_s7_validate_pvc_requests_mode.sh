#!/usr/bin/env bash
set -euo pipefail

NS="storage-hostpath"
PVC_NAME="earth-project-earthflower-pvc"

req=$(kubectl -n "${NS}" get pvc "${PVC_NAME}" -o jsonpath='{.spec.resources.requests.storage}')
am=$(kubectl -n "${NS}" get pvc "${PVC_NAME}" -o jsonpath='{range .spec.accessModes[*]}{.}{"\n"}{end}')

[[ "${req}" == "2Gi" ]] || { echo "PVC requested storage is '${req}', expected '2Gi'"; exit 1; }
echo "${am}" | grep -qx 'ReadWriteOnce' || { echo "PVC accessModes missing ReadWriteOnce"; exit 1; }

