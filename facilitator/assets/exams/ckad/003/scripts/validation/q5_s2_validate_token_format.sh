#!/usr/bin/env bash
set -euo pipefail

TOKEN_FILE="/opt/course/exam3/q05/token"

# This script checks that the token has the valid 3-part JWT structure.
if [ ! -f "$TOKEN_FILE" ]; then
    # Exit gracefully if file doesn't exist, as a separate check handles that.
    exit 0
fi

TOKEN=$(cat "$TOKEN_FILE")
if [[ ! "$TOKEN" =~ ^[A-Za-z0-9_-]+\.[A-Za-z0-9_-]+\.[A-Za-z0-9_-]+$ ]]; then
    exit 1
fi

exit 0
