#!/usr/bin/env bash
set -euo pipefail
kubectl get ns ckad-q16 >/dev/null 2>&1 || kubectl create ns ckad-q16

cat > /opt/course/exam3/q16/cleaner.yaml <<'EOF'
apiVersion: apps/v1
kind: Deployment
metadata:
  name: cleaner
  namespace: ckad-q16
spec:
  replicas: 1
  selector:
    matchLabels: {app: cleaner}
  template:
    metadata:
      labels: {app: cleaner}
    spec:
      containers:
      - name: cleaner-con
        image: busybox:1.31.0
        command: ["/bin/sh","-c","mkdir -p /var/log/cleaner; while true; do date >> /var/log/cleaner/cleaner.log; sleep 2; done"]
        volumeMounts:
        - name: logs
          mountPath: /var/log/cleaner
      volumes:
      - name: logs
        emptyDir: {}
EOF

kubectl apply -f /opt/course/exam3/q16/cleaner.yaml
mkdir -p /opt/course/exam3/q16

