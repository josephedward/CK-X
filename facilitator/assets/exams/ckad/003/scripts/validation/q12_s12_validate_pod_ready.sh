#!/usr/bin/env bash
set -euo pipefail

NS="storage-hostpath"
DEPLOY="project-earthflower"

ready=$(kubectl -n "${NS}" get deploy "${DEPLOY}" -o jsonpath='{.status.readyReplicas}')
replicas=$(kubectl -n "${NS}" get deploy "${DEPLOY}" -o jsonpath='{.spec.replicas}')

[[ -z "${replicas}" ]] && replicas=1

if [[ "${ready}" == "${replicas}" && -n "${ready}" ]]; then
  exit 0
else
  echo "Deployment readyReplicas=${ready}, expected ${replicas}"
  exit 1
fi

