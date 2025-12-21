#!/bin/bash
# Q16.02 - Liveness probe configured correctly

# Get the liveness probe command and arguments
COMMAND=$(kubectl get pod live-check -n liveness-probes -o jsonpath='{.spec.containers[0].livenessProbe.exec.command}')

# The expected command is a JSON array string '["cat","/tmp/healthy"]'
EXPECTED_COMMAND='["cat","/tmp/healthy"]'

if [ "$COMMAND" == "$EXPECTED_COMMAND" ]; then
  echo "✓ Liveness probe exec command configured correctly"
  exit 0
else
  echo "✗ Liveness probe not configured as expected"
  echo "Expected: $EXPECTED_COMMAND"
  echo "Got: $COMMAND"
  exit 1
fi
