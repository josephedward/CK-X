#!/usr/bin/env bash
set -euo pipefail
kubectl get ns ckad-q15 >/dev/null 2>&1 || kubectl create ns ckad-q15

# Seed deployment that expects a configmap named configmap-web-moon-html
cat <<'EOF' | kubectl apply -f -
apiVersion: apps/v1
kind: Deployment
metadata:
  name: web-moon
  namespace: ckad-q15
spec:
  replicas: 1
  selector:
    matchLabels: {app: web-moon}
  template:
    metadata:
      labels: {app: web-moon}
    spec:
      containers:
      - name: nginx
        image: nginx:1.21.6-alpine
        volumeMounts:
        - name: html
          mountPath: /usr/share/nginx/html
      volumes:
      - name: html
        configMap:
          name: configmap-web-moon-html
EOF

mkdir -p /opt/course/exam3/q15
cat > /opt/course/exam3/q15/web-moon.html <<'EOF'
<html>
  <body>Welcome to Moonpie!</body>
</html>
EOF

