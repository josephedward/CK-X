#!/bin/bash
# Validate that the security profile exists

PROFILE_NAME="restricted-profile"
NAMESPACE="seccomp"

# Check if the pod security policy exists as a ConfigMap
kubectl get configmap $PROFILE_NAME -n $NAMESPACE &> /dev/null
if [ $? -ne 0 ]; then
  echo "❌ Security profile ConfigMap '$PROFILE_NAME' not found in namespace '$NAMESPACE'"
  exit 1
fi

# Check if the ConfigMap has the seccomp profile content
PROFILE_CONTENT=$(kubectl get configmap $PROFILE_NAME -n $NAMESPACE -o jsonpath='{.data.profile\.json}')
if [ -z "$PROFILE_CONTENT" ]; then
  echo "❌ Security profile does not contain the required 'profile.json' key in ConfigMap"
  exit 1
fi

# Check if the profile content has the expected fields
if [[ "$PROFILE_CONTENT" != *"defaultAction"* ]] || [[ "$PROFILE_CONTENT" != *"syscalls"* ]]; then
  echo "❌ Security profile does not have the required content (defaultAction and syscalls fields)"
  exit 1
fi

echo "✅ Security profile exists and has required content"
exit 0 