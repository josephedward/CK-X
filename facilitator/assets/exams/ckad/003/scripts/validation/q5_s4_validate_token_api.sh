#!/usr/bin/env bash
set -euo pipefail

TOKEN_FILE="/opt/course/exam3/q05/token"
NAMESPACE="service-accounts"

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

# Check if the token can be used to authenticate a basic API request.
# We check if the service account can get its own definition.
# The `|| true` is to prevent the script from exiting if the kubectl command fails.
# We explicitly check the output for "yes".
AUTH_RESULT=$(kubectl auth can-i get serviceaccount neptune-sa-v2 --namespace="$NAMESPACE" --token="$TOKEN" 2>/dev/null || true)

if [[ "$AUTH_RESULT" != "yes" ]]; then
    exit 1
fi

exit 0
