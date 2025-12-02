#!/usr/bin/env bash
set -euo pipefail
kubectl get ns ckad-q08 >/dev/null 2>&1 || kubectl create ns ckad-q08

# Create a working deployment, then introduce a bad revision
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

# Record a bad image to break rollout
kubectl -n ckad-q08 set image deploy/api-new-c32 api=nginx:does-not-exist --record=true || true

mkdir -p /opt/course/exam3/q08

