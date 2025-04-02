#!/bin/bash
# Validate that the pod uses the security profile

POD_NAME="seccomp-pod"
NAMESPACE="seccomp"
PROFILE_NAME="restricted-profile"

# Check if the pod exists
kubectl get pod $POD_NAME -n $NAMESPACE &> /dev/null
if [ $? -ne 0 ]; then
  echo "❌ Pod '$POD_NAME' not found in namespace '$NAMESPACE'"
  exit 1
fi

# Check if the pod uses a seccomp profile
SECCOMP_PROFILE=$(kubectl get pod $POD_NAME -n $NAMESPACE -o jsonpath='{.spec.securityContext.seccompProfile.type}')
if [ "$SECCOMP_PROFILE" != "Localhost" ]; then
  echo "❌ Pod does not use a Localhost seccomp profile. Found: $SECCOMP_PROFILE"
  exit 1
fi

# Check if the pod uses the correct seccomp profile path
SECCOMP_PATH=$(kubectl get pod $POD_NAME -n $NAMESPACE -o jsonpath='{.spec.securityContext.seccompProfile.localhostProfile}')
if [[ "$SECCOMP_PATH" != *"$PROFILE_NAME"* ]] && [[ "$SECCOMP_PATH" != *"profile.json"* ]]; then
  echo "❌ Pod does not use the correct seccomp profile path. Found: $SECCOMP_PATH"
  exit 1
fi

echo "✅ Pod uses the correct seccomp profile"
exit 0 