#!/bin/bash
# Validator for Q6 - Container Command
# Checks if the container was started with the correct command.
c1=$(kubectl get pod pod6 -n readiness -o jsonpath='{.spec.containers[0].command[0]}' 2>/dev/null)
c2=$(kubectl get pod pod6 -n readiness -o jsonpath='{.spec.containers[0].command[1]}' 2>/dev/null)
c3=$(kubectl get pod pod6 -n readiness -o jsonpath='{.spec.containers[0].command[2]}' 2>/dev/null)

if [[ "$c1" == "/bin/sh" && "$c2" == "-c" && "$c3" == "touch /tmp/ready && sleep 1d" ]]; then
  exit 0
else
  exit 1
fi
