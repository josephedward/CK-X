#!/bin/bash
set -e

NAMESPACE="helm-operations"

kubectl create namespace $NAMESPACE --dry-run=client -o yaml | kubectl apply -f -

# Label a worker node for affinity testing (target specific worker node if available)
kubectl label node node-01 disktype=ssd --overwrite 2>/dev/null || echo "Labeling skipped, node may not exist"

# Create pod requiring node affinity
cat <<EOF | kubectl apply -f -
apiVersion: v1
kind: Pod
metadata:
  name: affinity-pod
  namespace: $NAMESPACE
spec:
  affinity:
    nodeAffinity:
      requiredDuringSchedulingIgnoredDuringExecution:
        nodeSelectorTerms:
        - matchExpressions:
          - key: disktype
            operator: In
            values:
            - ssd
  containers:
  - name: app
    image: nginx:latest
    ports:
    - containerPort: 80
EOF

echo "✓ Q21 setup complete: Pod with node affinity created in namespace $NAMESPACE"
