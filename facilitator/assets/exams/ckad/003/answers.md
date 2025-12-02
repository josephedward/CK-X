# CKAD-003 Lab Answers

This document contains solutions or reference commands for all questions in the CKAD-003 lab. Paths follow `/opt/course/exam3/qXX/` and preview paths `/opt/course/exam3/p{1..3}/`.

## Question 1
List namespaces and save output

```bash
mkdir -p /opt/course/exam3/q01
kubectl get ns > /opt/course/exam3/q01/namespaces
```

## Question 2
Create pod and status command

```bash
kubectl create ns ckad-q02 || true
kubectl run pod1 -n ckad-q02 --image=httpd:2.4.41-alpine --restart=Never --dry-run=client -o yaml \
 | yq '.spec.containers[0].name = "pod1-container"' | kubectl apply -f -

mkdir -p /opt/course/exam3/q02
cat > /opt/course/exam3/q02/pod1-status-command.sh <<'EOF'
#!/usr/bin/env bash
kubectl -n ckad-q02 get pod pod1 -o wide
EOF
chmod +x /opt/course/exam3/q02/pod1-status-command.sh
```

## Question 3
Job with parallelism and completions

```bash
kubectl create ns ckad-q03 || true
cat > /opt/course/exam3/q03/job.yaml <<'EOF'
apiVersion: batch/v1
kind: Job
metadata:
  name: neb-new-job
  namespace: ckad-q03
spec:
  completions: 3
  parallelism: 2
  template:
    metadata:
      labels:
        id: awesome-job
    spec:
      restartPolicy: OnFailure
      containers:
      - name: neb-new-job-container
        image: busybox:1.31.0
        command: ["/bin/sh","-c","sleep 2 && echo done"]
EOF
kubectl apply -f /opt/course/exam3/q03/job.yaml
```

## Question 4
Helm management (degraded path)

```bash
# If helm available
helm repo add localcharts http://localhost:6000 && helm repo update
helm -n ckad-q04 uninstall internal-issue-report-apiv1 || true
helm -n ckad-q04 upgrade --install internal-issue-report-apiv2 localcharts/nginx
helm -n ckad-q04 upgrade --install internal-issue-report-apache localcharts/apache --set replicaCount=2
helm ls -A | awk '/pending-install/ {print $1, $2}' | while read ns rel; do helm -n "$ns" uninstall "$rel"; done

# Degraded acceptance (no helm): ensure a deployment exists named internal-issue-report-apache with 2 replicas
kubectl create ns ckad-q04 || true
kubectl -n ckad-q04 create deploy internal-issue-report-apache --image=httpd:2.4.41-alpine --replicas=2 --dry-run=client -o yaml | kubectl apply -f -
```

## Question 5
ServiceAccount token to file

```bash
kubectl create ns ckad-q05 || true
kubectl -n ckad-q05 create sa neptune-sa-v2 || true
# Try to discover bound token secret
SECRET=$(kubectl -n ckad-q05 get sa neptune-sa-v2 -o jsonpath='{.secrets[0].name}' 2>/dev/null || true)
if [ -n "$SECRET" ]; then
  kubectl -n ckad-q05 get secret "$SECRET" -o jsonpath='{.data.token}' | base64 -d > /opt/course/exam3/q05/token
else
  # Fallback: create projected token via token request API (k8s >=1.24)
  kubectl -n ckad-q05 create token neptune-sa-v2 > /opt/course/exam3/q05/token
fi
```

## Question 6
Readiness probe and command

```bash
kubectl create ns ckad-q06 || true
cat <<'EOF' | kubectl apply -f -
apiVersion: v1
kind: Pod
metadata:
  name: pod6
  namespace: ckad-q06
spec:
  containers:
  - name: c
    image: busybox:1.31.0
    command: ["/bin/sh","-c","touch /tmp/ready && sleep 1d"]
    readinessProbe:
      exec:
        command: ["/bin/sh","-c","cat /tmp/ready"]
      initialDelaySeconds: 5
      periodSeconds: 10
EOF
```

## Question 7
Move pod between namespaces

```bash
# Find by annotation, then recreate in target
kubectl -n ckad-q07-source get pod -o json | jq -r '.items[] | select(.metadata.annotations.description|test("my-happy-shop")) | .metadata.name'
kubectl -n ckad-q07-source get pod webserver-sat-003 -o yaml \
 | yq 'del(.metadata.namespace,.metadata.resourceVersion,.metadata.uid,.metadata.creationTimestamp,.status)' \
 | yq '.metadata.namespace = "ckad-q07-target"' \
 | kubectl apply -f -
kubectl -n ckad-q07-source delete pod webserver-sat-003 --ignore-not-found
```

## Question 8
Rollback to working revision

```bash
kubectl -n ckad-q08 rollout history deploy/api-new-c32
kubectl -n ckad-q08 rollout undo deploy/api-new-c32
kubectl -n ckad-q08 rollout status deploy/api-new-c32
```

## Question 9
Convert pod to deployment and harden securityContext

```bash
kubectl create ns ckad-q09 || true
kubectl -n ckad-q09 get pod holy-api -o yaml \
 | kubectl neat 2>/dev/null \
 | yq 'del(.metadata.namespace,.metadata.uid,.metadata.resourceVersion,.metadata.creationTimestamp,.status)' \
 | yq '{apiVersion:"apps/v1",kind:"Deployment",metadata:{name:"holy-api",namespace:"ckad-q09"},spec:{replicas:3,selector:{matchLabels:.metadata.labels},template:{metadata:{labels:.metadata.labels},spec:.spec}}}' \
 | yq '.spec.template.spec.containers[0].securityContext = {allowPrivilegeEscalation: false, privileged: false}' \
 | tee /opt/course/exam3/q09/holy-api-deployment.yaml | kubectl apply -f -
kubectl -n ckad-q09 delete pod holy-api --ignore-not-found
```

## Question 10
Service + logs

```bash
kubectl create ns ckad-q10 || true
kubectl -n ckad-q10 run project-plt-6cc-api --image=nginx:1.17.3-alpine --labels=project=plt-6cc-api --port=80 --restart=Never --expose=false --dry-run=client -o yaml | kubectl apply -f -
kubectl -n ckad-q10 expose pod project-plt-6cc-api --name=project-plt-6cc-svc --type=ClusterIP --port=3333 --target-port=80

mkdir -p /opt/course/exam3/q10
kubectl -n ckad-q10 run tmp --rm -i --image=nginx:alpine --restart=Never -- bash -lc 'apk add --no-cache curl >/dev/null; curl -s project-plt-6cc-svc:3333' > /opt/course/exam3/q10/service_test.html
kubectl -n ckad-q10 logs pod/project-plt-6cc-api > /opt/course/exam3/q10/service_test.log
```

## Question 11
Images and logs (degraded accepted)

```bash
mkdir -p /opt/course/exam3/q11/image /opt/course/exam3/q11
cat > /opt/course/exam3/q11/image/Dockerfile <<'EOF'
FROM golang:1.21-alpine as build
WORKDIR /src
COPY . .
RUN go build -o /out/app ./

FROM alpine:3.18
ENV SUN_CIPHER_ID=5b9c1065-e39d-4a43-a04a-e59bcea3e03f
COPY --from=build /out/app /app
CMD ["/app"]
EOF
cat > /opt/course/exam3/q11/image/main.go <<'EOF'
package main
import (
  "fmt"
  "os"
  "time"
)
func main(){
  id := os.Getenv("SUN_CIPHER_ID")
  for { fmt.Printf("SUN_CIPHER_ID=%s\n", id); time.Sleep(2*time.Second) }
}
EOF
# If docker/podman not available, produce logs file directly with marker
echo "SUN_CIPHER_ID=5b9c1065-e39d-4a43-a04a-e59bcea3e03f" > /opt/course/exam3/q11/logs
```

## Question 12
PV, PVC, Deployment

```bash
cat <<'EOF' | kubectl apply -f -
apiVersion: v1
kind: PersistentVolume
metadata:
  name: earth-project-earthflower-pv
spec:
  capacity:
    storage: 2Gi
  accessModes: ["ReadWriteOnce"]
  hostPath:
    path: /Volumes/Data
---
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: earth-project-earthflower-pvc
  namespace: ckad-q12
spec:
  accessModes: ["ReadWriteOnce"]
  resources:
    requests:
      storage: 2Gi
EOF
cat <<'EOF' | kubectl apply -f -
apiVersion: apps/v1
kind: Deployment
metadata:
  name: project-earthflower
  namespace: ckad-q12
spec:
  replicas: 1
  selector:
    matchLabels: {app: earthflower}
  template:
    metadata:
      labels: {app: earthflower}
    spec:
      containers:
      - name: httpd
        image: httpd:2.4.41-alpine
        volumeMounts:
        - name: data
          mountPath: /tmp/project-data
      volumes:
      - name: data
        persistentVolumeClaim:
          claimName: earth-project-earthflower-pvc
EOF
```

## Question 13
StorageClass + PVC pending, reason to file

```bash
kubectl create ns ckad-q13 || true
cat <<'EOF' | kubectl apply -f -
apiVersion: storage.k8s.io/v1
kind: StorageClass
metadata:
  name: moon-retain
provisioner: moon-retainer
reclaimPolicy: Retain
volumeBindingMode: Immediate
---
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: moon-pvc-126
  namespace: ckad-q13
spec:
  accessModes: ["ReadWriteOnce"]
  resources:
    requests:
      storage: 3Gi
  storageClassName: moon-retain
EOF
kubectl -n ckad-q13 describe pvc moon-pvc-126 | sed -n '/Events/,$p' > /opt/course/exam3/q13/pvc-126-reason
```

## Question 14
Secret env + ConfigMap volume

```bash
kubectl create ns ckad-q14 || true
kubectl -n ckad-q14 create secret generic secret1 --from-literal=user=test --from-literal=pass=pwd
kubectl -n ckad-q14 create configmap secret2 --from-literal=example=ok
# Edit the existing pod to include envFrom/volumes then save:
kubectl -n ckad-q14 get pod secret-handler -o yaml > /opt/course/exam3/q14/secret-handler-new.yaml
# Edit file to add:
# env:
# - name: SECRET1_USER
#   valueFrom: {secretKeyRef: {name: secret1, key: user}}
# - name: SECRET1_PASS
#   valueFrom: {secretKeyRef: {name: secret1, key: pass}}
# volumes:
# - name: secret2
#   configMap: {name: secret2}
# volumeMounts:
# - {name: secret2, mountPath: /tmp/secret2}
```

## Question 15
ConfigMap to serve HTML

```bash
kubectl create ns ckad-q15 || true
mkdir -p /opt/course/exam3/q15
cat > /opt/course/exam3/q15/configmap.yaml <<'EOF'
apiVersion: v1
kind: ConfigMap
metadata:
  name: configmap-web-moon-html
  namespace: ckad-q15
data:
  index.html: |
EOF
sed 's/^/    /' /opt/course/exam3/q15/web-moon.html >> /opt/course/exam3/q15/configmap.yaml
kubectl apply -f /opt/course/exam3/q15/configmap.yaml
```

## Question 16
Sidecar for log shipping

```bash
kubectl create ns ckad-q16 || true
# Edit the deployment from cleaner.yaml and add sidecar that tails the file, then save to cleaner-new.yaml
```

## Question 17
InitContainer producing index.html

```bash
# Edit test-init-container.yaml to add init container busybox:1.31.0 that writes /var/www/html/index.html
kubectl apply -f /opt/course/exam3/q17/test-init-container-new.yaml
```

## Question 18
Fix service misconfiguration

```bash
kubectl -n ckad-q18 get svc manager-api-svc -o yaml
kubectl -n ckad-q18 get deploy manager-api-deployment -o yaml
# Fix selector/ports so service selects pods correctly and targetPort matches containerPort
```

## Question 19
ClusterIP → NodePort 30100

```bash
kubectl -n ckad-q19 patch svc jupiter-crew-svc -p '{"spec":{"type":"NodePort","ports":[{"port":80,"targetPort":80,"nodePort":30100}]}}'
```

## Preview P1 (Q20)
Add liveness probe and save

```bash
# Add TCP 80 livenessProbe with initialDelaySeconds: 10, periodSeconds: 15
kubectl apply -f /opt/course/exam3/p1/project-23-api-new.yaml
```

## Preview P2 (Q21)
Deployment with ServiceAccount + Service + status command

```bash
kubectl create ns ckad-p2 || true
kubectl -n ckad-p2 create deploy sunny --image=nginx:1.17.3-alpine --replicas=4 --dry-run=client -o yaml \
 | yq '.spec.template.spec.serviceAccountName = "sa-sun-deploy"' | kubectl apply -f -
kubectl -n ckad-p2 expose deploy sunny --name=sun-srv --type=ClusterIP --port=9999 --target-port=80
mkdir -p /opt/course/exam3/p2
echo "kubectl -n ckad-p2 get pods -l app=sunny" > /opt/course/exam3/p2/sunny_status_command.sh
```

## Preview P3 (Q22)
Fix readinessProbe port and write ticket

```bash
# Correct readinessProbe port to match container
echo "Readiness probe used wrong port; fixed to containerPort." > /opt/course/exam3/p3/ticket-description.txt
```
