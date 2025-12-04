#!/usr/bin/env bash
set -euo pipefail

TOKEN_FILE="/opt/course/exam3/q05/token"

if [ ! -f "$TOKEN_FILE" ]; then
    exit 1
fi

# Decode the token and check for JWT format
DECODED_TOKEN=$(cat "$TOKEN_FILE" | base64 -d 2>/dev/null)

if [[ ! "$DECODED_TOKEN" =~ ^[A-Za-z0-9_-]+\.[A-Za-z0-9_-]+\.[A-Za-z0-9_-]+$ ]]; then
    exit 1
fi

exit 0
