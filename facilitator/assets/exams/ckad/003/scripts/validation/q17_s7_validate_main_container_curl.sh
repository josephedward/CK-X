#!/usr/bin/env bash
set -euo pipefail
# Verifies that curling the service returns 'check this out!'
# First, get the pod name
POD_NAME=$(kubectl -n init-container get pod -l app=init-web -o jsonpath='{.items[0].metadata.name}')

# Try to curl the service from within the pod
CURL_RESULT=$(kubectl -n init-container exec $POD_NAME -- curl -s http://localhost)

if [[ "$CURL_RESULT" != *"check this out!"* ]]; then
    echo "Curl result does not contain expected content: $CURL_RESULT"
    exit 1
fi