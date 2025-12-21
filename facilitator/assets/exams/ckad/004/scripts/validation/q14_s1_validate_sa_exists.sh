#!/usr/bin/env bash
# Q14.01 - ServiceAccount exists
# Points: 2

if kubectl get serviceaccount app-sa -n service-accounts >/dev/null 2>&1; then
  echo "✓ ServiceAccount app-sa exists in service-accounts"
  exit 0
else
  echo "✗ ServiceAccount app-sa not found in service-accounts"
  exit 1
fi
