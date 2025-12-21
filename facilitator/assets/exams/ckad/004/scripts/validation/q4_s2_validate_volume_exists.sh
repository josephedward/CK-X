#!/usr/bin/env bash
# Q04.02 - Shared emptyDir volume defined (shared-log)
# Points: 2

NS="sidecar-logging"

# Check if the shared-log volume exists and is of type emptyDir
V=$(kubectl get pod logger-pod -n "$NS" -o jsonpath='{.spec.volumes[?(@.name=="shared-log")].emptyDir}' 2>/dev/null)

# Check if the value is not empty
if [ -n "$V" ]; then
    echo "✓ emptyDir volume 'shared-log' defined"
    exit 0
else
    echo "✗ emptyDir volume 'shared-log' not found"
    exit 1
fi
