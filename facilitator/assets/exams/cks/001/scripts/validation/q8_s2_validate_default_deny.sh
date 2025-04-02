#!/bin/bash
# Validate that the security profile has default deny

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

# Check if the profile has defaultAction set to SCMP_ACT_ERRNO
DEFAULT_ACTION=$(echo "$PROFILE_CONTENT" | grep -o '"defaultAction":[[:space:]]*"[^"]*"' | cut -d'"' -f4)
if [ "$DEFAULT_ACTION" != "SCMP_ACT_ERRNO" ]; then
  echo "❌ Security profile does not have defaultAction set to SCMP_ACT_ERRNO. Found: $DEFAULT_ACTION"
  exit 1
fi

echo "✅ Security profile has default deny (defaultAction: SCMP_ACT_ERRNO)"
exit 0