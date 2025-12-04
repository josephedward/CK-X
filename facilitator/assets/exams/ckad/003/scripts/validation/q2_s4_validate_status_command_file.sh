#!/usr/bin/env bash
set -euo pipefail

USER_SCRIPT="/opt/course/exam3/q02/pod1-status-command.sh"

# Check if the user's script exists and is executable
if [ ! -x "$USER_SCRIPT" ]; then
    # If not executable, try to make it executable
    chmod +x "$USER_SCRIPT" || exit 1
fi

# Execute the user's script and capture the output
user_output=$("$USER_SCRIPT")

# Execute the canonical command and capture the output
# The namespace is single-pod, but the question context implies the command should work within the context of the question, so I will add the namespace
canonical_output=$(kubectl -n single-pod get pod pod1 -o jsonpath='{.status.phase}')

# Compare the outputs
if [ "$user_output" == "$canonical_output" ]; then
    exit 0
else
    exit 1
fi