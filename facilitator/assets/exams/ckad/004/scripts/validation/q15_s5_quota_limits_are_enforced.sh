#!/bin/bash
# Q15.5 - Quota limits are enforced
# Points: 2

HARD_PODS=$(kubectl get quota ns-quota -n quota-ns -o jsonpath='{.status.hard.pods}' 2>/dev/null)

if [[ -n "$HARD_PODS" ]] && [[ "$HARD_PODS" =~ ^[0-9]+$ ]] && [[ "$HARD_PODS" -gt 0 ]]; then
  echo "✓ Quota limits are defined (hard limit: $HARD_PODS pods)"
  exit 0
else
  echo "✗ Quota limits not defined"
  exit 1
fi
