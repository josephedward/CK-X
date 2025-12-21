#!/usr/bin/env bash
# Q04.04 - Sidecar container mounts volume at /var/log
# Points: 2

NS="sidecar-logging"

# Get the mountPath for the sidecar container's shared-log volume mount
MP=$(kubectl get pod logger-pod -n "$NS" -o jsonpath='{.spec.containers[?(@.name=="sidecar")].volumeMounts[?(@.name=="shared-log")].mountPath}' 2>/dev/null)

# Check if the mountPath is /var/log
if [ "$MP" = "/var/log" ]; then
    echo "✓ Sidecar container mounts shared-log at /var/log"
    exit 0
else
    echo "✗ Sidecar container mountPath is '$MP', expected '/var/log'"
    exit 1
fi
