#!/usr/bin/env bash
set -euo pipefail
kubectl get ns ckad-q19 >/dev/null 2>&1 || kubectl create ns ckad-q19

cat <<'EOF' | kubectl apply -f -
apiVersion: apps/v1
kind: Deployment
metadata:
  name: jupiter-crew-deploy
  namespace: ckad-q19
spec:
  replicas: 1
  selector:
    matchLabels: {app: jupiter}
  template:
    metadata:
      labels: {app: jupiter}
    spec:
      containers:
      - name: web
        image: httpd:2.4.41-alpine
        ports:
        - containerPort: 80
EOF

cat <<'EOF' | kubectl apply -f -
apiVersion: v1
kind: Service
metadata:
  name: jupiter-crew-svc
  namespace: ckad-q19
spec:
  type: ClusterIP
  selector:
    app: jupiter
  ports:
  - port: 80
    targetPort: 80
    protocol: TCP
EOF

mkdir -p /opt/course/exam3/q19

