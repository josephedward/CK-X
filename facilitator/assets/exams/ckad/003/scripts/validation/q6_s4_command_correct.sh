#!/bin/bash
# Validator for Q6 - Container Command (effect-based, startup-verification)
# Goal: verify the container itself created the ready flag during startup.
# Policy: be flexible with syntax; accept common equivalents beyond
#         strictly "touch /tmp/ready && sleep ...".

set -e

# Ensure the pod exists before attempting exec
kubectl -n readiness get pod pod6 >/dev/null 2>&1 || exit 1

# 1) The ready flag must exist
kubectl -n readiness exec pod6 -- sh -c 'test -f /tmp/ready' >/dev/null 2>&1 || exit 1

# 2) Inspect PID 1 command line for evidence that startup created the file.
# Accept if the cmdline references the ready path, or uses common file-creation utilities.
CMDLINE=$(kubectl -n readiness exec pod6 -- sh -c "cat /proc/1/cmdline | tr '\\0' ' '" 2>/dev/null || true)

# Accept if the command line references the ready file path directly
if echo "$CMDLINE" | grep -qE "/tmp/ready"; then
  exit 0
fi

# Otherwise, accept if common creators are present (touch/echo/printf/install/tee) as a proxy
if echo "$CMDLINE" | grep -qE "\\b(touch|echo|printf|install|tee)\\b"; then
  exit 0
fi

# If neither pattern matched, consider it not created during startup
exit 1
