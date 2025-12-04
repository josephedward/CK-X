#!/bin/bash
# Validator for Q6 - Readiness Probe Command
# Checks if the readiness probe is configured with the correct command.
c1=$(kubectl get pod pod6 -n readiness -o jsonpath='{.spec.containers[0].readinessProbe.exec.command[0]}' 2>/dev/null)
c2=$(kubectl get pod pod6 -n readiness -o jsonpath='{.spec.containers[0].readinessProbe.exec.command[1]}' 2>/dev/null)
c3=$(kubectl get pod pod6 -n readiness -o jsonpath='{.spec.containers[0].readinessProbe.exec.command[2]}' 2>/dev/null)

# Accommodate both `cat /tmp/ready` and `sh -c 'cat /tmp/ready'`
if [[ "$c1" == "cat" && "$c2" == "/tmp/ready" ]]; then
  exit 0
elif [[ "$c1" == "/bin/sh" && "$c2" == "-c" && "$c3" == "cat /tmp/ready" ]]; then
  exit 0
else
  exit 1
fi
