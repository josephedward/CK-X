#!/bin/bash
# Validate that service account is configured properly

SA_NAME="api-explorer"
NAMESPACE="api-explorer"

# Check if namespace exists
kubectl get namespace $NAMESPACE &> /dev/null
if [ $? -ne 0 ]; then
  echo "❌ Namespace '$NAMESPACE' not found"
  exit 1
fi

# Check if the service account exists
kubectl get serviceaccount $SA_NAME -n $NAMESPACE &> /dev/null
if [ $? -ne 0 ]; then
  echo "❌ ServiceAccount '$SA_NAME' not found in namespace '$NAMESPACE'"
  exit 1
fi

# Check if there's a token secret for this service account
TOKEN_NAME=$(kubectl get serviceaccount $SA_NAME -n $NAMESPACE -o jsonpath='{.secrets[0].name}' 2>/dev/null)
if [ -z "$TOKEN_NAME" ]; then
  # Check if we're using Kubernetes v1.24+ where tokens are created manually
  TOKEN_NAME=$(kubectl get secrets -n $NAMESPACE -o jsonpath='{.items[?(@.metadata.annotations.kubernetes\.io/service-account\.name=="'$SA_NAME'")].metadata.name}' 2>/dev/null)
  if [ -z "$TOKEN_NAME" ]; then
    echo "❌ No token found for ServiceAccount '$SA_NAME'"
    exit 1
  fi
fi

# Get the token secret details
TOKEN_DATA=$(kubectl get secret $TOKEN_NAME -n $NAMESPACE -o jsonpath='{.data.token}' 2>/dev/null)
if [ -z "$TOKEN_DATA" ]; then
  echo "❌ Token data not found for ServiceAccount '$SA_NAME'"
  exit 1
fi

echo "✅ ServiceAccount is configured properly"
exit 0 