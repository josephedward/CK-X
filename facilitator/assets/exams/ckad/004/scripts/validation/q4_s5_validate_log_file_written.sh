#!/usr/bin/env bash
# Q04.05 - App writes to log file, visible via sidecar
# Points: 2

NS="sidecar-logging"
LOGS=$(kubectl logs logger-pod -n "$NS" -c sidecar 2>/dev/null | tail -n 20)

# Check if the logs contain "logging info"
if [[ "$LOGS" == *"logging info"* ]]; then
    echo "✓ Sidecar outputs 'logging info' from shared log"
    exit 0
else
    echo "✗ Expected 'logging info' not found in sidecar logs"
    exit 1
fi
