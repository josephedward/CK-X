#!/usr/bin/env bash
set -euo pipefail

TOKEN_FILE="/opt/course/exam3/q05/token"
NAMESPACE="service-accounts"
SA_NAME="neptune-sa-v2"
EXPECTED_WHOAMI="system:serviceaccount:${NAMESPACE}:${SA_NAME}"

# This script uses the k8s API to validate the token's authenticity.
if [ ! -f "$TOKEN_FILE" ]; then
    # Exit gracefully if file doesn't exist, as other checks handle that.
    exit 0
fi

TOKEN=$(cat "$TOKEN_FILE")
# Basic format check to prevent errors
if ! [[ "$TOKEN" =~ ^[A-Za-z0-9_-]+\.[A-Za-z0-9_-]+\.[A-Za-z0-9_-]+$ ]]; then
    exit 0
fi

# Use 'kubectl whoami' to validate authentication. This is a more direct
# check of the token's identity than 'auth can-i', which tests authorization.
WHOAMI_RESULT=$(kubectl whoami --token="$TOKEN" 2>/dev/null || true)

if [[ "$WHOAMI_RESULT" != "$EXPECTED_WHOAMI" ]]; then
    exit 1
fi

exit 0