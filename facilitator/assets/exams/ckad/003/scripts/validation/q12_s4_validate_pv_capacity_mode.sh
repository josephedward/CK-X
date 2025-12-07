#!/usr/bin/env bash
set -euo pipefail

PV_NAME="earth-project-earthflower-pv"

cap=$(kubectl get pv "${PV_NAME}" -o jsonpath='{.spec.capacity.storage}')
am=$(kubectl get pv "${PV_NAME}" -o jsonpath='{range .spec.accessModes[*]}{.}{"\n"}{end}')

[[ "${cap}" == "2Gi" ]] || { echo "PV capacity is '${cap}', expected '2Gi'"; exit 1; }
echo "${am}" | grep -qx 'ReadWriteOnce' || { echo "PV accessModes missing ReadWriteOnce"; exit 1; }

