#!/bin/bash
# Validator for Q6 - Container Command (effect-based, startup-verification)
# Accept equivalent implementations, but ensure the ready file is present AND
# that PID 1 was started with a command that includes creating it (not manual exec).

# Ensure the pod exists before attempting exec
kubectl -n readiness get pod pod6 >/dev/null 2>&1 || exit 1

# 1) The ready flag must exist
kubectl -n readiness exec pod6 -- sh -c 'test -f /tmp/ready' >/dev/null 2>&1 || exit 1

# 2) PID 1 command line should include tokens indicating startup script created it
CMDLINE=$(kubectl -n readiness exec pod6 -- sh -c "cat /proc/1/cmdline | tr '\\0' ' '" 2>/dev/null)
echo "$CMDLINE" | grep -q "touch" || exit 1
echo "$CMDLINE" | grep -q "/tmp/ready" || exit 1
echo "$CMDLINE" | grep -q "sleep" || exit 1

exit 0
