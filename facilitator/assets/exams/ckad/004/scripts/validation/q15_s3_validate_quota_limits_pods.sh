#!/usr/bin/env bash
# Q15.03 - ResourceQuota limits pods to 5
# Points: 4

VAL=$(kubectl get resourcequota ns-quota -n quota-ns -o jsonpath='{.spec.hard.pods}')
VAL_CLEAN="${VAL//$'\n'/}"  # Remove newlines
if [[ "$VAL_CLEAN" == "5" ]]; then
  echo "✓ ResourceQuota limits pods to 5"
  exit 0
else
  echo "✗ ResourceQuota pods hard limit is '$VAL', expected '5'"
  exit 1
fi
