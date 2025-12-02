#!/usr/bin/env bash
set -euo pipefail
kubectl get ns ckad-q08 >/dev/null 2>&1 || kubectl create ns ckad-q08

# Create a working deployment and wait for it to be ready.
# This establishes a "good" revision in the history.
cat <<'EOF' | kubectl apply -f -
apiVersion: apps/v1
kind: Deployment
metadata:
  name: api-new-c32
  namespace: ckad-q08
spec:
  replicas: 1
  selector:
    matchLabels:
      app: api-new-c32
  template:
    metadata:
      labels:
        app: api-new-c32
    spec:
      containers:
      - name: api
        image: nginx:1.21.6-alpine
        ports:
        - containerPort: 80
EOF

# Wait for the initial deployment to be fully rolled out and ready.
kubectl -n ckad-q08 rollout status deployment/api-new-c32 --timeout=60s

# Now, introduce a bad revision by updating the image to one that does not exist.
# This creates a broken state that the user must roll back from.
kubectl -n ckad-q08 set image deploy/api-new-c32 api=nginx:does-not-exist --record=true || true

mkdir -p /opt/course/exam3/q08
