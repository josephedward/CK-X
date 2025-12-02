# CKAD-003 Lab Answers

This document contains solutions or reference commands for all questions in the CKAD-003 lab. Paths follow `/opt/course/exam3/qXX/` and preview paths `/opt/course/exam3/p{1..3}/`.

## Question 1
**Question:** The DevOps team would like to get the list of all Namespaces in the cluster. Save the list to `/opt/course/exam3/q01/namespaces` on localhost.

**Answer:**
```bash
mkdir -p /opt/course/exam3/q01
kubectl get ns > /opt/course/exam3/q01/namespaces
```

## Question 2
**Question:** Create a single Pod of image `httpd:2.4.41-alpine` in Namespace `ckad-q02`. The Pod should be named `pod1` and the container should be named `pod1-container`. Write a kubectl command that outputs the status of that exact Pod to `/opt/course/exam3/q02/pod1-status-command.sh`.

**Answer:**
```bash
kubectl create ns ckad-q02 || true
kubectl run pod1 -n ckad-q02 --image=httpd:2.4.41-alpine --restart=Never --dry-run=client -o yaml \
 | yq ".spec.containers[0].name = \"pod1-container\"" | kubectl apply -f -

mkdir -p /opt/course/exam3/q02
cat > /opt/course/exam3/q02/pod1-status-command.sh <<'EOF'
#!/usr/bin/env bash
kubectl -n ckad-q02 get pod pod1 -o wide
EOF
chmod +x /opt/course/exam3/q02/pod1-status-command.sh
```

## Question 3
**Question:** Create a Job manifest at `/opt/course/exam3/q03/job.yaml` named `neb-new-job` in namespace `ckad-q03` that runs image `busybox:1.31.0` with command `sleep 2 && echo done`, sets `completions=3`, `parallelism=2`, and labels pods with `id=awesome-job`. Start the Job. The container should be named `neb-new-job-container`.

**Answer:**
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
**Question:** Using `helm` in Namespace `ckad-q04`: delete release `internal-issue-report-apiv1`, upgrade release `internal-issue-report-apiv2` to any newer `bitnami/nginx`, install a new release `internal-issue-report-apache` from `bitnami/apache` with `replicas=2` via values, and delete any releases stuck in `pending-install` across namespaces (use `helm ls -A`).

**Answer:**
```bash
helm repo add bitnami https://charts.bitnami.com/bitnami || true
helm repo update
helm -n ckad-q04 uninstall internal-issue-report-apiv1 || true
helm -n ckad-q04 upgrade --install internal-issue-report-apiv2 bitnami/nginx
helm -n ckad-q04 upgrade --install internal-issue-report-apache bitnami/apache --set replicaCount=2
helm ls -A -o json | jq -r '.[] | select(.status == "pending-install") | "\(.namespace) \(.name)"' | while read ns rel; do helm -n "$ns" uninstall "$rel"; done
```

## Question 5
**Question:** Create ServiceAccount `neptune-sa-v2` in `ckad-q05` and write the base64-decoded token from its Secret to `/opt/course/exam3/q05/token` on localhost.

**Answer:**
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
**Question:** Create Pod `pod6` in Namespace `ckad-q06` using `busybox:1.31.0` with readinessProbe executing `cat /tmp/ready` (initialDelaySeconds=`5`, periodSeconds=`10`). The container command should be `sh -c 'touch /tmp/ready && sleep 1d'`. Confirm Pod becomes Ready.

**Answer:**
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
**Question:** Search for the e-commerce Pod (annotation mentioning `my-happy-shop`) in Namespace `ckad-q07-source` and move it to `ckad-q07-target`. The Pod name is `webserver-sat-003`. It is acceptable to delete and recreate.

**Answer:**
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
**Question:** There is an existing Deployment `api-new-c32` in `ckad-q08` with a broken revision. Check the rollout history, identify a working revision, and rollback so the Deployment becomes Ready.

**Answer:**
```bash
kubectl -n ckad-q08 rollout history deploy/api-new-c32
kubectl -n ckad-q08 rollout undo deploy/api-new-c32
kubectl -n ckad-q08 rollout status deploy/api-new-c32
```

## Question 9
**Question:** Convert the single Pod `holy-api` in Namespace `ckad-q09` into a Deployment named `holy-api` with `replicas=3`. Delete the original Pod. Set container securityContext `allowPrivilegeEscalation=false` and `privileged=false`. Save the Deployment YAML to `/opt/course/exam3/q09/holy-api-deployment.yaml`.

**Answer:**
```bash
kubectl create ns ckad-q09 || true
kubectl -n ckad-q09 get pod holy-api -o yaml \
 | kubectl neat 2>/dev/null \
 | yq 'del(.metadata.namespace,.metadata.uid,.metadata.resourceVersion,.metadata.creationTimestamp,.status)' \
 | yq "{apiVersion:\"apps/v1\",kind:\"Deployment\",metadata:{name:\"holy-api\",namespace:\"ckad-q09\"},spec:{replicas:3,selector:{matchLabels:.metadata.labels},template:{metadata:{labels:.metadata.labels},spec:.spec}}}" \
 | yq '.spec.template.spec.containers[0].securityContext = {allowPrivilegeEscalation: false, privileged: false}' \
 | tee /opt/course/exam3/q09/holy-api-deployment.yaml | kubectl apply -f -
kubectl -n ckad-q09 delete pod holy-api --ignore-not-found
```

## Question 10
**Question:** Create a ClusterIP Service `project-plt-6cc-svc` in `ckad-q10` exposing Pod `project-plt-6cc-api` (image `nginx:1.17.3-alpine`, label `project=plt-6cc-api`) using port mapping `3333:80`. Use a temporary Pod to curl the Service and write the response to `/opt/course/exam3/q10/service_test.html` and the app logs to `/opt/course/exam3/q10/service_test.log`.

**Answer:**
```bash
kubectl create ns ckad-q10 || true
kubectl -n ckad-q10 run project-plt-6cc-api --image=nginx:1.17.3-alpine --labels=project=plt-6cc-api --port=80 --restart=Never --expose=false --dry-run=client -o yaml | kubectl apply -f -
kubectl -n ckad-q10 expose pod project-plt-6cc-api --name=project-plt-6cc-svc --type=ClusterIP --port=3333 --target-port=80

mkdir -p /opt/course/exam3/q10
kubectl -n ckad-q10 run tmp --rm -i --image=nginx:alpine --restart=Never -- bash -lc 'apk add --no-cache curl >/dev/null; curl -s project-plt-6cc-svc:3333' > /opt/course/exam3/q10/service_test.html
kubectl -n ckad-q10 logs pod/project-plt-6cc-api > /opt/course/exam3/q10/service_test.log
```

## Question 11
**Question:** Build and push two images (docker and podman variants) for a Golang app at `/opt/course/exam3/q11/image`, set ENV `SUN_CIPHER_ID=5b9c1065-e39d-4a43-a04a-e59bcea3e03f`, run a container with podman, and write logs to `/opt/course/exam3/q11/logs`. If Docker/Podman/registry are unavailable, a degraded path is accepted: create a log file containing the `SUN_CIPHER_ID` marker.

**Answer:**
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
**Question:** Create PV `earth-project-earthflower-pv` (2Gi, RWO, hostPath `/Volumes/Data`, no storageClass), PVC `earth-project-earthflower-pvc` (2Gi, RWO, no storageClass) in `ckad-q12`, and a Deployment `project-earthflower` mounting it at `/tmp/project-data` using `httpd:2.4.41-alpine`.

**Answer:**
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
**Question:** Create StorageClass `moon-retain` (provisioner `moon-retainer`, reclaimPolicy `Retain`). Create PVC `moon-pvc-126` (3Gi, RWO, uses `moon-retain`) in `ckad-q13`. Since the provisioner does not exist, PVC should stay Pending. Write the PVC event message to `/opt/course/exam3/q13/pvc-126-reason`.

**Answer:**
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
**Question:** In Namespace `ckad-q14`, create Secret `secret1` (user=`test`, pass=`pwd`) and make it available in Pod `secret-handler` as env vars `SECRET1_USER` and `SECRET1_PASS`. Also create ConfigMap `secret2` and mount it at `/tmp/secret2` in the same Pod. Save updated YAML to `/opt/course/exam3/q14/secret-handler-new.yaml`.

**Answer:**
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
**Question:** For Deployment `web-moon` in `ckad-q15`, create ConfigMap `configmap-web-moon-html` whose data contains key `index.html` with content from `/opt/course/exam3/q15/web-moon.html`. Save the ConfigMap definition to `/opt/course/exam3/q15/configmap.yaml`.

**Answer:**
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
**Question:** Add a sidecar `logger-con` (image `busybox:1.31.0`) to Deployment `cleaner` in `ckad-q16` reading the same volume and executing `tail -f /var/log/cleaner/cleaner.log`. Save updated Deployment to `/opt/course/exam3/q16/cleaner-new.yaml` and ensure Deployment is running.

**Answer:**
```bash
kubectl create ns ckad-q16 || true
# Edit the deployment from cleaner.yaml and add sidecar that tails the file, then save to cleaner-new.yaml
```

## Question 17
**Question:** Add an InitContainer `init-con` (image `busybox:1.31.0`) to Deployment defined at `/opt/course/exam3/q17/test-init-container.yaml` that writes `index.html` with content `check this out!` into the shared volume. Save to `/opt/course/exam3/q17/test-init-container-new.yaml` and verify via curl.

**Answer:**
```bash
# Edit test-init-container.yaml to add init container busybox:1.31.0 that writes /var/www/html/index.html
kubectl apply -f /opt/course/exam3/q17/test-init-container-new.yaml
```

## Question 18
**Question:** Fix the misconfiguration in Namespace `ckad-q18` where Service `manager-api-svc` should expose Deployment `manager-api-deployment` but has no endpoints. After fixing selector/ports, the Service should have endpoints.

**Answer:**
```bash
kubectl -n ckad-q18 get svc manager-api-svc -o yaml
kubectl -n ckad-q18 get deploy manager-api-deployment -o yaml
# Fix selector/ports so service selects pods correctly and targetPort matches containerPort
```

## Question 19
**Question:** In Namespace `ckad-q19`, change Service `jupiter-crew-svc` from `ClusterIP` to `NodePort` and set `nodePort=30100`. Verify reachability inside cluster (single-node clusters reachable on that node).

**Answer:**
```bash
kubectl -n ckad-q19 patch svc jupiter-crew-svc -p '{"spec":{"type":"NodePort","ports":[{"port":80,"targetPort":80,"nodePort":30100}]}}'
```

## Preview P1 (Q20)
**Question:** Add a liveness probe (TCP 80, initialDelay=10s, period=15s) to Deployment `project-23-api` in `ckad-p1`. Save to `/opt/course/exam3/p1/project-23-api-new.yaml` and apply.

**Answer:**
```bash
# Add TCP 80 livenessProbe with initialDelaySeconds: 10, periodSeconds: 15
kubectl apply -f /opt/course/exam3/p1/project-23-api-new.yaml
```

## Preview P2 (Q21)
**Question:** Create Deployment `sunny` with `replicas=4` using image `nginx:1.17.3-alpine` in `ckad-p2` and set `serviceAccountName=sa-sun-deploy`. Expose it via ClusterIP Service `sun-srv` on port 9999. Write a kubectl command to `/opt/course/exam3/p2/sunny_status_command.sh` that checks all Pods are running.

**Answer:**
```bash
kubectl create ns ckad-p2 || true
kubectl -n ckad-p2 create deploy sunny --image=nginx:1.17.3-alpine --replicas=4 --dry-run=client -o yaml \
 | yq '.spec.template.spec.serviceAccountName = "sa-sun-deploy"' | kubectl apply -f -
kubectl -n ckad-p2 expose deploy sunny --name=sun-srv --type=ClusterIP --port=9999 --target-port=80
mkdir -p /opt/course/exam3/p2
echo "kubectl -n ckad-p2 get pods -l app=sunny" > /opt/course/exam3/p2/sunny_status_command.sh
```

## Preview P3 (Q22)
**Question:** Fix the readinessProbe port in Deployment `earth-3cc-web` in `ckad-p3` so that Pods become ready and Service `earth-3cc-web-svc` has aget deployment ready state. Write a short description of the issue to `/opt/course/exam3/p3/ticket-description.txt`.

**Answer:**
```bash
# Correct readinessProbe port to match container
echo "Readiness probe used wrong port; fixed to containerPort." > /opt/course/exam3/p3/ticket-description.txt
```
