#!/bin/bash
set -e

NAMESPACE="secrets-volume"

kubectl create namespace $NAMESPACE --dry-run=client -o yaml | kubectl apply -f -

# Create the app-secret with required keys
kubectl create secret generic app-secret \
  --namespace $NAMESPACE \
  --from-literal=api-key=123456 \
  --from-literal=username=admin

# Create pod that mounts the secret
cat <<EOF | kubectl apply -f -
apiVersion: v1
kind: Pod
metadata:
  name: sec-pod
  namespace: $NAMESPACE
spec:
  containers:
  - name: app
    image: busybox:latest
    command: ['sh', '-c', 'while true; do echo "$(date): Application running"; sleep 5; done']
    volumeMounts:
    - name: app-secret-volume
      mountPath: /etc/app-secret
  volumes:
  - name: app-secret-volume
    secret:
      secretName: app-secret
EOF

echo "✓ Q12 setup complete: Secret app-secret created and mounted in pod sec-pod in namespace $NAMESPACE"
