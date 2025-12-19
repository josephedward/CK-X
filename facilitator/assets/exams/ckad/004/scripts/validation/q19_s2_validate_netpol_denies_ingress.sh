#!/bin/bash
# Q19.02 - NetworkPolicy denies ingress (no ingress rules)
# Points: 4 (will update weightage in assessment.json)

NS="network-policies"
NETPOL_SPEC=$(kubectl get networkpolicy default-deny -n "$NS" -o json 2>/dev/null)

if [ -z "$NETPOL_SPEC" ]; then
  echo "✗ NetworkPolicy default-deny not found in namespace $NS"
  exit 1
fi

INGRESS_POLICY_TYPE=$(echo "$NETPOL_SPEC" | jq -r '.spec.policyTypes[]? | select(. == "Ingress")')
INGRESS_RULES=$(echo "$NETPOL_SPEC" | jq '.spec.ingress | length')
POD_SELECTOR_EMPTY=$(echo "$NETPOL_SPEC" | jq '(.spec.podSelector | length) == 0')

if [[ "$INGRESS_POLICY_TYPE" == "Ingress" ]] && \
   [[ "$INGRESS_RULES" == "0" ]] && \
   [[ "$POD_SELECTOR_EMPTY" == "true" ]]; then
  echo "✓ NetworkPolicy correctly denies all ingress traffic to all pods"
  exit 0
else
  echo "✗ NetworkPolicy not configured correctly"
  echo "   - Policy Type Ingress: $INGRESS_POLICY_TYPE"
  echo "   - Ingress Rules Count: $INGRESS_RULES"
  echo "   - Pod Selector Empty: $POD_SELECTOR_EMPTY"
  exit 1
fi