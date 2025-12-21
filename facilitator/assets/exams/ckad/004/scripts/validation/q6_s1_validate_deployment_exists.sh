#!/usr/bin/env bash
# Q06.01 - Deployment web-deploy exists
# Points: 2

NS="deployments-scaling"
if kubectl get deploy web-deploy -n "$NS" >/dev/null 2>&1; then
  echo "✓ Deployment web-deploy exists in $NS"
  exit 0
else
  echo "✗ Deployment web-deploy not found in $NS"
  exit 1
fi
