#!/bin/bash
set -e

NAMESPACE="readiness-probes"

kubectl create namespace $NAMESPACE --dry-run=client -o yaml | kubectl apply -f -

# Create pod with readiness probe
cat <<EOF | kubectl apply -f -
apiVersion: v1
kind: Pod
metadata:
  name: ready-web
  namespace: $NAMESPACE
spec:
  containers:
  - name: nginx-container
    image: nginx
    ports:
    - containerPort: 80
    readinessProbe:
      httpGet:
        path: /
        port: 80
      initialDelaySeconds: 5
      periodSeconds: 10
EOF

echo "✓ Q17 setup complete: Pod with readiness probe created in namespace $NAMESPACE"
