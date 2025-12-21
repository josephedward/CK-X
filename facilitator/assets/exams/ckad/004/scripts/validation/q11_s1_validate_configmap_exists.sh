#!/usr/bin/env bash
# Q11.01 - ConfigMap app-config exists
# Points: 2

NS="configmaps-env"
if kubectl get configmap app-config -n "$NS" >/dev/null 2>&1; then
  echo "✓ ConfigMap app-config exists in $NS"
  exit 0
else
  echo "✗ ConfigMap app-config not found in $NS"
  exit 1
fi
