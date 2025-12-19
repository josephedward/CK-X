#!/usr/bin/env bash
# Q12.01 - Secret app-secret exists
# Points: 2

NS="secrets-volume"
if kubectl get secret app-secret -n "$NS" >/dev/null 2>&1; then
  echo "✓ Secret app-secret exists in $NS"
  exit 0
else
  echo "✗ Secret app-secret not found in $NS"
  exit 1
fi
