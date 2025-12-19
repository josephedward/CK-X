#!/bin/bash
# Q16.4 - Liveness probe is configured
# Points: 2

PROBE_COMMAND=$(kubectl get pod live-check -n liveness-probes -o jsonpath='{.spec.containers[0].livenessProbe.exec.command}' 2>/dev/null)

if echo "$PROBE_COMMAND" | grep -q 'cat' && echo "$PROBE_COMMAND" | grep -q '/tmp/healthy'; then
  echo "✓ Liveness probe is configured with correct exec command"
  exit 0
else
  echo "✗ Liveness probe not configured with correct exec command"
  exit 1
fi
