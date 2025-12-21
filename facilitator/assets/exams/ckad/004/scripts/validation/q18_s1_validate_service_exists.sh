#!/usr/bin/env bash
# Q18.01 - Service web-svc exists
# Points: 2

NS="services-clusterip"
if kubectl get svc web-svc -n "$NS" >/dev/null 2>&1; then
  echo "✓ Service web-svc exists in $NS"
  exit 0
else
  echo "✗ Service web-svc not found in $NS"
  exit 1
fi
