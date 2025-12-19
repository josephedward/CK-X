#!/usr/bin/env bash
# Q19.01 - NetworkPolicy default-deny exists
# Points: 3

NS="network-policies"
if kubectl get networkpolicy default-deny -n "$NS" >/dev/null 2>&1; then
  echo "✓ NetworkPolicy default-deny exists in $NS"
  exit 0
else
  echo "✗ NetworkPolicy default-deny not found in $NS"
  exit 1
fi
