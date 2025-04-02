#!/bin/bash
# Validate that the ClusterRoleBinding 'read-pods' correctly associates the 'pod-reader' role with user 'jane'

CLUSTERROLEBINDING_NAME="read-pods"
CLUSTERROLE_NAME="pod-reader"
USER_NAME="jane"
NAMESPACE="cluster-admin"

# Check if the ClusterRoleBinding exists
kubectl get clusterrolebinding $CLUSTERROLEBINDING_NAME > /dev/null 2>&1
if [ $? -ne 0 ]; then
  echo "❌ ClusterRoleBinding '$CLUSTERROLEBINDING_NAME' not found"
  exit 1
fi

# Check if the ClusterRoleBinding references the correct ClusterRole
ROLE_REF=$(kubectl get clusterrolebinding $CLUSTERROLEBINDING_NAME -o jsonpath='{.roleRef.name}' 2>/dev/null)

if [ "$ROLE_REF" != "$CLUSTERROLE_NAME" ]; then
  echo "❌ ClusterRoleBinding '$CLUSTERROLEBINDING_NAME' references role '$ROLE_REF' instead of '$CLUSTERROLE_NAME'"
  exit 1
fi

# Check the roleRef kind - should be ClusterRole
ROLE_KIND=$(kubectl get clusterrolebinding $CLUSTERROLEBINDING_NAME -o jsonpath='{.roleRef.kind}' 2>/dev/null)

if [ "$ROLE_KIND" != "ClusterRole" ]; then
  echo "❌ ClusterRoleBinding '$CLUSTERROLEBINDING_NAME' references a '$ROLE_KIND' instead of a 'ClusterRole'"
  exit 1
fi

# Check if the ClusterRoleBinding has a subject for user 'jane'
SUBJECTS=$(kubectl get clusterrolebinding $CLUSTERROLEBINDING_NAME -o json | jq -r '.subjects[] | select(.name=="jane" and .kind=="User")' 2>/dev/null)

if [ -z "$SUBJECTS" ]; then
  echo "❌ ClusterRoleBinding '$CLUSTERROLEBINDING_NAME' does not bind to user '$USER_NAME'"
  exit 1
fi

# Check if the namespace of the subject is specified as 'cluster-admin'
SUBJECT_NS=$(kubectl get clusterrolebinding $CLUSTERROLEBINDING_NAME -o json | jq -r '.subjects[] | select(.name=="jane" and .kind=="User") | .namespace' 2>/dev/null)

if [ "$SUBJECT_NS" != "$NAMESPACE" ] && [ "$SUBJECT_NS" != "null" ]; then
  echo "❌ ClusterRoleBinding subject namespace is '$SUBJECT_NS' instead of '$NAMESPACE'"
  exit 1
fi

# Success
echo "✅ ClusterRoleBinding '$CLUSTERROLEBINDING_NAME' correctly associates ClusterRole '$CLUSTERROLE_NAME' with user '$USER_NAME'"
echo "✅ This binding grants Jane read-only access to pod resources across all namespaces"
exit 0 