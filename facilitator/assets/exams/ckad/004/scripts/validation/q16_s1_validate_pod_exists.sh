#!/usr/bin/env bash
# Q16.01 - Pod live-check exists
# Points: 2

NS="liveness-probes"
if kubectl get pod live-check -n "$NS" >/dev/null 2>&1; then
  echo "✓ Pod live-check exists in $NS"
  exit 0
else
  echo "✗ Pod live-check not found in $NS"
  exit 1
fi
