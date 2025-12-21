#!/usr/bin/env bash
# Q15.02 - ResourceQuota ns-quota exists in quota-ns
# Points: 2

if kubectl get resourcequota ns-quota -n quota-ns >/dev/null 2>&1; then
  echo "✓ ResourceQuota ns-quota exists in quota-ns"
  exit 0
else
  echo "✗ ResourceQuota ns-quota not found in quota-ns"
  exit 1
fi
