#!/usr/bin/env bash
# Q09.04 - Job pod exited with success code
# Points: 2

NS="batch-jobs"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
. "$SCRIPT_DIR/../lib/common.sh"

POD=$(first_pod_name_by_label "$NS" 'job-name=batch-job')
if [[ -z "$POD" ]]; then
  fail "No pod found for job batch-job"
fi

# Get the container exit code
EXIT_CODE=$(kubectl get pod "$POD" -n "$NS" -o jsonpath='{.status.containerStatuses[0].state.terminated.exitCode}' 2>/dev/null)

if [[ "$EXIT_CODE" == "0" ]]; then
  ok "Job pod exited with success code (0)"
else
  fail "Job pod exited with code $EXIT_CODE (expected 0)"
fi