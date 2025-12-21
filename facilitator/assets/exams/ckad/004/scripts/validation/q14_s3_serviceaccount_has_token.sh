#!/bin/bash
# Q14.3 - ServiceAccount has token
# Points: 2

# Modern approach for Kubernetes 1.24+
# Try to create a token - if successful, the ServiceAccount exists and can authenticate
if kubectl create token backend-sa -n service-accounts --duration=1s >/dev/null 2>&1; then
  echo "✓ ServiceAccount can authenticate (token creation successful)"
  exit 0
else
  echo "✗ ServiceAccount cannot authenticate (token creation failed)"
  exit 1
fi
