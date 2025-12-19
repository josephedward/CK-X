#!/usr/bin/env bash
# Q07.01 - Strategy is RollingUpdate
# Points: 2

NS="rolling-updates"
STRAT=$(kubectl get deploy web-deploy -n "$NS" -o jsonpath='{.spec.strategy.type}')
if [[ "$STRAT" == "RollingUpdate" ]]; then
  echo "✓ Update strategy is RollingUpdate"
  exit 0
else
  echo "✗ Strategy is '$STRAT', expected 'RollingUpdate'"
  exit 1
fi
