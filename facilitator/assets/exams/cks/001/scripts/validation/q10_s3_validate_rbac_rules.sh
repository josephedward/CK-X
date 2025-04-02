#!/bin/bash
# Validate that RBAC rules are properly configured

SA_NAME="api-explorer"
NAMESPACE="api-explorer"
ROLE_NAME="api-explorer-role"
ROLEBINDING_NAME="api-explorer-binding"

# Check if namespace exists
kubectl get namespace $NAMESPACE &> /dev/null
if [ $? -ne 0 ]; then
  echo "❌ Namespace '$NAMESPACE' not found"
  exit 1
fi

# Check if Role exists
kubectl get role $ROLE_NAME -n $NAMESPACE &> /dev/null
if [ $? -ne 0 ]; then
  echo "❌ Role '$ROLE_NAME' not found in namespace '$NAMESPACE'"
  exit 1
fi

# Check if RoleBinding exists
kubectl get rolebinding $ROLEBINDING_NAME -n $NAMESPACE &> /dev/null
if [ $? -ne 0 ]; then
  echo "❌ RoleBinding '$ROLEBINDING_NAME' not found in namespace '$NAMESPACE'"
  exit 1
fi

# Check if Role has proper rules (can list/get/watch pods and services)
RESOURCES=$(kubectl get role $ROLE_NAME -n $NAMESPACE -o jsonpath='{.rules[*].resources}')
if [[ "$RESOURCES" != *"pods"* ]] || [[ "$RESOURCES" != *"services"* ]]; then
  echo "❌ Role does not have access to required resources (pods and services)"
  exit 1
fi

VERBS=$(kubectl get role $ROLE_NAME -n $NAMESPACE -o jsonpath='{.rules[*].verbs}')
if [[ "$VERBS" != *"get"* ]] || [[ "$VERBS" != *"list"* ]] || [[ "$VERBS" != *"watch"* ]]; then
  echo "❌ Role does not have required verbs (get, list, watch)"
  exit 1
fi

# Check if RoleBinding references the correct Role
REFERENCED_ROLE=$(kubectl get rolebinding $ROLEBINDING_NAME -n $NAMESPACE -o jsonpath='{.roleRef.name}')
if [ "$REFERENCED_ROLE" != "$ROLE_NAME" ]; then
  echo "❌ RoleBinding references incorrect Role. Expected: $ROLE_NAME, Got: $REFERENCED_ROLE"
  exit 1
fi

# Check if RoleBinding is bound to the correct ServiceAccount
SUBJECT_NAME=$(kubectl get rolebinding $ROLEBINDING_NAME -n $NAMESPACE -o jsonpath='{.subjects[0].name}')
if [ "$SUBJECT_NAME" != "$SA_NAME" ]; then
  echo "❌ RoleBinding not bound to correct ServiceAccount. Expected: $SA_NAME, Got: $SUBJECT_NAME"
  exit 1
fi

# Verify that the role doesn't allow deletion or modification operations
if [[ "$VERBS" == *"delete"* ]] || [[ "$VERBS" == *"create"* ]] || [[ "$VERBS" == *"update"* ]] || [[ "$VERBS" == *"patch"* ]]; then
  echo "❌ Role allows modification operations (create/update/delete/patch) which should be restricted"
  exit 1
fi

echo "✅ RBAC rules are properly configured"
exit 0 