#!/bin/bash
# Validate that pod has proper API access

POD_NAME="api-explorer"
NAMESPACE="api-explorer"

# Check if namespace exists
kubectl get namespace $NAMESPACE &> /dev/null
if [ $? -ne 0 ]; then
  echo "❌ Namespace '$NAMESPACE' not found"
  exit 1
fi

# Check if the pod exists
kubectl get pod $POD_NAME -n $NAMESPACE &> /dev/null
if [ $? -ne 0 ]; then
  echo "❌ Pod '$POD_NAME' not found in namespace '$NAMESPACE'"
  exit 1
fi

# Check if the pod is running
POD_STATUS=$(kubectl get pod $POD_NAME -n $NAMESPACE -o jsonpath='{.status.phase}')
if [ "$POD_STATUS" != "Running" ]; then
  echo "❌ Pod '$POD_NAME' is not running. Current status: $POD_STATUS"
  exit 1
fi

# Check if the pod is using the correct service account
POD_SA=$(kubectl get pod $POD_NAME -n $NAMESPACE -o jsonpath='{.spec.serviceAccountName}')
if [ "$POD_SA" != "api-explorer" ]; then
  echo "❌ Pod is not using the correct ServiceAccount. Expected: api-explorer, Got: $POD_SA"
  exit 1
fi

# Test API access from within the pod
# List pods in the current namespace to verify read access
LIST_PODS=$(kubectl exec $POD_NAME -n $NAMESPACE -- curl -s https://kubernetes.default.svc/api/v1/namespaces/$NAMESPACE/pods -k -H "Authorization: Bearer $(cat /var/run/secrets/kubernetes.io/serviceaccount/token)")
if [[ "$LIST_PODS" == *"pods"* ]]; then
  echo "✅ Pod has proper API access"
  exit 0
else
  echo "❌ Pod cannot access the Kubernetes API properly"
  exit 1
fi 