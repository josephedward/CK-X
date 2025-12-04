#!/usr/bin/env bash
set -euo pipefail

TOKEN_FILE="/opt/course/exam3/q05/token"

if [ ! -f "$TOKEN_FILE" ]; then
    exit 1
fi

# Check for JWT format
TOKEN=$(cat "$TOKEN_FILE")

if [[ ! "$TOKEN" =~ ^[A-Za-z0-9_-]+\.[A-Za-z0-9_-]+\.[A-Za-z0-9_-]+$ ]]; then
    exit 1
fi

exit 0
