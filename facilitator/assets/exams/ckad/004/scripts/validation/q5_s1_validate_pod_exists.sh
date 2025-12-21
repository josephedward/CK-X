#!/usr/bin/env bash
# Q05.01 - All 3 pods (pod-a, pod-b, pod-c) exist
# Points: 2

NS="labels-selectors"
missing=0
for p in pod-a pod-b pod-c; do
  if ! kubectl get pod "$p" -n "$NS" >/dev/null 2>&1; then
    echo "✗ Pod $p not found in $NS"
    missing=1
  fi
done

if [[ "$missing" -eq 0 ]]; then
  echo "✓ All 3 pods exist in $NS"
  exit 0
else
  echo "✗ One or more pods missing in $NS"
  exit 1
fi
