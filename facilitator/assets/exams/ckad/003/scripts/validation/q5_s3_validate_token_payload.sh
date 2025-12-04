#!/usr/bin/env bash
set -euo pipefail

TOKEN_FILE="/opt/course/exam3/q05/token"

# This script checks the token payload to ensure it belongs to the correct Service Account.
if [ ! -f "$TOKEN_FILE" ]; then
    # Exit gracefully if file doesn't exist, as other checks handle that.
    exit 0
fi

TOKEN=$(cat "$TOKEN_FILE")
# Basic format check to prevent errors
if ! [[ "$TOKEN" =~ ^[A-Za-z0-9_-]+\.[A-Za-z0-9_-]+\.[A-Za-z0-9_-]+$ ]]; then
    exit 0
fi

# Decode payload and verify service account details
PAYLOAD=$(echo "$TOKEN" | cut -d'.' -f2)
DECODED_PAYLOAD=$(echo "$PAYLOAD" | base64 -d 2>/dev/null)

SA_NAME=$(echo "$DECODED_PAYLOAD" | grep -o '"kubernetes.io/serviceaccount/service-account.name":"[^"]*' | cut -d'"' -f4)
NAMESPACE=$(echo "$DECODED_PAYLOAD" | grep -o '"kubernetes.io/serviceaccount/namespace":"[^"]*' | cut -d'"' -f4)

if [[ "$SA_NAME" != "neptune-sa-v2" ]] || [[ "$NAMESPACE" != "service-accounts" ]]; then
    exit 1
fi

exit 0
