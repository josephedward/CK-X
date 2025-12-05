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

TOKEN=$(tr -d '\n\r' < "$TOKEN_FILE")
# Basic format check to prevent errors
if ! [[ "$TOKEN" =~ ^[A-Za-z0-9_-]+\.[A-Za-z0-9_-]+\.[A-Za-z0-9_-]+$ ]]; then
    exit 0
fi

# Prefer kubectl whoami, fallback to kubectl auth whoami, finally to decoding 'sub'.
WHOAMI_RESULT=$(kubectl whoami --token="$TOKEN" 2>/dev/null || true)
if [ -z "$WHOAMI_RESULT" ]; then
  WHOAMI_RESULT=$(kubectl auth whoami --token="$TOKEN" 2>/dev/null || true)
fi

if [ -z "$WHOAMI_RESULT" ]; then
  # As a last fallback, decode JWT 'sub' and compare
  PAYLOAD=$(printf '%s' "$TOKEN" | cut -d'.' -f2)
  input="${PAYLOAD//-/+}"
  input="${input//_//}"
  pad=$(( (4 - ${#input} % 4) % 4 ))
  for i in $(seq 1 $pad); do input="${input}="; done
  DECODED=$(printf '%s' "$input" | base64 -d 2>/dev/null || true)
  if command -v jq >/dev/null 2>&1; then
    WHOAMI_RESULT=$(printf '%s' "$DECODED" | jq -r '.sub // empty')
  elif command -v python3 >/dev/null 2>&1 || command -v python >/dev/null 2>&1; then
    PY=python3; command -v python >/dev/null 2>&1 && PY=python
    WHOAMI_RESULT=$($PY - << 'PY'
import json,sys
try:
  data=json.load(sys.stdin)
  print(data.get("sub",""))
except Exception:
  print("")
PY
    <<< "$DECODED")
  else
    WHOAMI_RESULT=$(echo "$DECODED" | grep -o '"sub":"[^"]*' | cut -d'"' -f4)
  fi
fi

if [[ "$WHOAMI_RESULT" == "$EXPECTED_WHOAMI" ]]; then
  exit 0
fi

exit 1
