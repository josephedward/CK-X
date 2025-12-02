#!/usr/bin/env bash
set -euo pipefail
kubectl get ns ckad-q07-source >/dev/null 2>&1 || kubectl create ns ckad-q07-source
kubectl get ns ckad-q07-target >/dev/null 2>&1 || kubectl create ns ckad-q07-target

# Seed source pod with discoverable annotation
cat <<'EOF' | kubectl apply -f -
apiVersion: v1
kind: Pod
metadata:
  name: webserver-sat-003
  namespace: ckad-q07-source
  labels:
    app: web
  annotations:
    description: "this is the server for the E-Commerce System my-happy-shop"
spec:
  containers:
  - name: web
    image: nginx:1.16.1-alpine
EOF

mkdir -p /opt/course/exam3/q07

