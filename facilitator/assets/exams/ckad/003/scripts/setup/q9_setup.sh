#!/usr/bin/env bash
set -euo pipefail
kubectl get ns ckad-q09 >/dev/null 2>&1 || kubectl create ns ckad-q09

cat <<'EOF' | kubectl apply -f -
apiVersion: v1
kind: Pod
metadata:
  name: holy-api
  namespace: ckad-q09
  labels:
    app: holy-api
spec:
  containers:
  - name: holy
    image: nginx:1.21.6-alpine
    ports:
    - containerPort: 80
EOF

mkdir -p /opt/course/exam3/q09

