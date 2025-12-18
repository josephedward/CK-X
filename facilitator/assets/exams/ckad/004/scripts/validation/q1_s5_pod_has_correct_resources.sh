#!/bin/bash
# Q1.5 - Pod has correct resources (100m CPU, 128Mi memory)
# Points: 2

# Check if resources are configured with the correct values
CPU_REQUEST=$(kubectl get pod web-core -n ckad-ns-a -o jsonpath='{.spec.containers[0].resources.requests.cpu}')
MEMORY_REQUEST=$(kubectl get pod web-core -n ckad-ns-a -o jsonpath='{.spec.containers[0].resources.requests.memory}')

if [[ "$CPU_REQUEST" == "100m" && "$MEMORY_REQUEST" == "128Mi" ]]; then
  echo "✓ Pod has correct resource requests (CPU: 100m, Memory: 128Mi)"
  exit 0
else
  echo "✗ Pod resources not configured correctly (expected CPU: 100m, Memory: 128Mi, got CPU: ${CPU_REQUEST:-not set}, Memory: ${MEMORY_REQUEST:-not set})"
  exit 1
fi
