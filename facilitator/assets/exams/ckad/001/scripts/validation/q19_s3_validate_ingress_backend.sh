#!/bin/bash
# Validate that the Ingress 'api-ingress' in namespace 'networking' routes traffic to service 'api-service' on port 80

NAMESPACE="networking"
INGRESS_NAME="api-ingress"
EXPECTED_HOST="api.example.com"
EXPECTED_SERVICE="api-service"
EXPECTED_PORT=80

# Check if the ingress exists
kubectl get ingress $INGRESS_NAME -n $NAMESPACE > /dev/null 2>&1
if [ $? -ne 0 ]; then
  echo "❌ Ingress '$INGRESS_NAME' not found in namespace '$NAMESPACE'"
  exit 1
fi

# Check if the service exists
kubectl get service $EXPECTED_SERVICE -n $NAMESPACE > /dev/null 2>&1
if [ $? -ne 0 ]; then
  echo "⚠️  Service '$EXPECTED_SERVICE' not found in namespace '$NAMESPACE'"
  # Continue with validation as the service might be created later
fi

# Get API version to handle different Ingress structures
API_VERSION=$(kubectl get ingress $INGRESS_NAME -n $NAMESPACE -o jsonpath='{.apiVersion}' 2>/dev/null)
echo "ℹ️  Ingress API version: $API_VERSION"

# Handle different API versions (v1 vs v1beta1)
if [[ "$API_VERSION" == "networking.k8s.io/v1" ]]; then
  # For v1 API
  RULE_INDEX=$(kubectl get ingress $INGRESS_NAME -n $NAMESPACE -o json | jq -r --arg host "$EXPECTED_HOST" '.spec.rules | map(.host == $host) | index(true) // empty')
  
  if [ -z "$RULE_INDEX" ]; then
    echo "❌ No rule found for host '$EXPECTED_HOST'"
    exit 1
  fi
  
  # Check path-based rules
  PATHS=$(kubectl get ingress $INGRESS_NAME -n $NAMESPACE -o json | jq -r --argjson idx "$RULE_INDEX" '.spec.rules[$idx].http.paths[].path // "/"')
  
  for PATH in $PATHS; do
    # For each path, check the backend service
    BACKEND_SERVICE_NAME=$(kubectl get ingress $INGRESS_NAME -n $NAMESPACE -o json | jq -r --argjson idx "$RULE_INDEX" --arg path "$PATH" '.spec.rules[$idx].http.paths[] | select(.path == $path or (.path == null and $path == "/")).backend.service.name // empty')
    BACKEND_SERVICE_PORT=$(kubectl get ingress $INGRESS_NAME -n $NAMESPACE -o json | jq -r --argjson idx "$RULE_INDEX" --arg path "$PATH" '.spec.rules[$idx].http.paths[] | select(.path == $path or (.path == null and $path == "/")).backend.service.port.number // empty')
    
    # If port is not a number, try getting it as a name
    if [ -z "$BACKEND_SERVICE_PORT" ]; then
      BACKEND_SERVICE_PORT=$(kubectl get ingress $INGRESS_NAME -n $NAMESPACE -o json | jq -r --argjson idx "$RULE_INDEX" --arg path "$PATH" '.spec.rules[$idx].http.paths[] | select(.path == $path or (.path == null and $path == "/")).backend.service.port.name // empty')
    fi
    
    echo "🔍 Path '$PATH' routes to service: $BACKEND_SERVICE_NAME, port: $BACKEND_SERVICE_PORT"
    
    if [ "$BACKEND_SERVICE_NAME" = "$EXPECTED_SERVICE" ]; then
      # Check port
      if [ "$BACKEND_SERVICE_PORT" = "$EXPECTED_PORT" ] || [ "$BACKEND_SERVICE_PORT" = "http" ]; then
        echo "✅ Found correct backend service and port for path '$PATH'"
        exit 0
      else
        echo "⚠️  Service name matches but port is different: expected $EXPECTED_PORT, got $BACKEND_SERVICE_PORT"
      fi
    fi
  done
else
  # For v1beta1 or extensions/v1beta1 API
  RULE_INDEX=$(kubectl get ingress $INGRESS_NAME -n $NAMESPACE -o json | jq -r --arg host "$EXPECTED_HOST" '.spec.rules | map(.host == $host) | index(true) // empty')
  
  if [ -z "$RULE_INDEX" ]; then
    echo "❌ No rule found for host '$EXPECTED_HOST'"
    exit 1
  fi
  
  # Check path-based rules
  PATHS=$(kubectl get ingress $INGRESS_NAME -n $NAMESPACE -o json | jq -r --argjson idx "$RULE_INDEX" '.spec.rules[$idx].http.paths[].path // "/"')
  
  for PATH in $PATHS; do
    # For each path, check the backend service
    BACKEND_SERVICE_NAME=$(kubectl get ingress $INGRESS_NAME -n $NAMESPACE -o json | jq -r --argjson idx "$RULE_INDEX" --arg path "$PATH" '.spec.rules[$idx].http.paths[] | select(.path == $path or (.path == null and $path == "/")).backend.serviceName // empty')
    BACKEND_SERVICE_PORT=$(kubectl get ingress $INGRESS_NAME -n $NAMESPACE -o json | jq -r --argjson idx "$RULE_INDEX" --arg path "$PATH" '.spec.rules[$idx].http.paths[] | select(.path == $path or (.path == null and $path == "/")).backend.servicePort // empty')
    
    echo "🔍 Path '$PATH' routes to service: $BACKEND_SERVICE_NAME, port: $BACKEND_SERVICE_PORT"
    
    if [ "$BACKEND_SERVICE_NAME" = "$EXPECTED_SERVICE" ]; then
      # Check port - can be number or name
      if [ "$BACKEND_SERVICE_PORT" = "$EXPECTED_PORT" ] || [ "$BACKEND_SERVICE_PORT" = "http" ]; then
        echo "✅ Found correct backend service and port for path '$PATH'"
        exit 0
      else
        echo "⚠️  Service name matches but port is different: expected $EXPECTED_PORT, got $BACKEND_SERVICE_PORT"
      fi
    fi
  done
fi

# If we get here, we didn't find the expected backend
echo "❌ Ingress does not route traffic to '$EXPECTED_SERVICE' on port $EXPECTED_PORT for host '$EXPECTED_HOST'"
exit 1 