# CKAD-002 Lab Answers

This document contains solutions for all questions in the CKAD-002 lab, which is based on the CKAD-exercises repository by dgkanatsios.

## Question 1: Core Concepts

Create a namespace and a pod with labels:

```bash
# Create namespace
kubectl create namespace core-concepts

# Create pod with labels
kubectl run nginx-pod --image=nginx -n core-concepts --labels="app=web,env=prod"

# Or using YAML:
cat <<EOF | kubectl apply -f -
apiVersion: v1
kind: Namespace
metadata:
  name: core-concepts
---
apiVersion: v1
kind: Pod
metadata:
  name: nginx-pod
  namespace: core-concepts
  labels:
    app: web
    env: prod
spec:
  containers:
  - name: nginx
    image: nginx
EOF
```

## Question 2: Multi-container Pods

Create a multi-container pod with a shared volume:

```bash
# Create namespace
kubectl create namespace multi-container

# Create multi-container pod with shared volume
cat <<EOF | kubectl apply -f -
apiVersion: v1
kind: Namespace
metadata:
  name: multi-container
---
apiVersion: v1
kind: Pod
metadata:
  name: multi-container-pod
  namespace: multi-container
spec:
  containers:
  - name: main-container
    image: nginx
    volumeMounts:
    - name: log-volume
      mountPath: /var/log
  - name: sidecar-container
    image: busybox
    command: ['sh', '-c', 'while true; do echo $(date) >> /var/log/app.log; sleep 5; done']
    volumeMounts:
    - name: log-volume
      mountPath: /var/log
  volumes:
  - name: log-volume
    emptyDir: {}
EOF
```

## Question 3: Pod Design - Deployment & Service

Create a deployment and a service:

```bash
# Create namespace
kubectl create namespace pod-design

# Create deployment and service
cat <<EOF | kubectl apply -f -
apiVersion: v1
kind: Namespace
metadata:
  name: pod-design
---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: frontend
  namespace: pod-design
  labels:
    app: frontend
    tier: frontend
spec:
  replicas: 3
  selector:
    matchLabels:
      app: frontend
      tier: frontend
  template:
    metadata:
      labels:
        app: frontend
        tier: frontend
    spec:
      containers:
      - name: nginx
        image: nginx:1.19.0
        ports:
        - containerPort: 80
---
apiVersion: v1
kind: Service
metadata:
  name: frontend-svc
  namespace: pod-design
spec:
  selector:
    app: frontend
    tier: frontend
  ports:
  - port: 80
    targetPort: 80
  type: ClusterIP
EOF
```

## Question 4: Configuration - ConfigMaps & Secrets

Create ConfigMap, Secret, and Pod using them:

```bash
# Create namespace
kubectl create namespace configuration

# Create ConfigMap
kubectl create configmap app-config -n configuration \
  --from-literal=DB_HOST=mysql \
  --from-literal=DB_PORT=3306 \
  --from-literal=DB_NAME=myapp

# Create Secret
kubectl create secret generic app-secret -n configuration \
  --from-literal=DB_USER=admin \
  --from-literal=DB_PASSWORD=s3cr3t

# Create Pod using ConfigMap and Secret
cat <<EOF | kubectl apply -f -
apiVersion: v1
kind: Pod
metadata:
  name: app-pod
  namespace: configuration
spec:
  containers:
  - name: nginx
    image: nginx
    envFrom:
    - configMapRef:
        name: app-config
    volumeMounts:
    - name: secret-volume
      mountPath: /etc/app-secret
      readOnly: true
  volumes:
  - name: secret-volume
    secret:
      secretName: app-secret
EOF
```

## Question 5: Observability - Probes & Resource Limits

Create a pod with liveness/readiness probes and resource limits:

```bash
# Create namespace
kubectl create namespace observability

# Create pod with probes and resource limits
cat <<EOF | kubectl apply -f -
apiVersion: v1
kind: Namespace
metadata:
  name: observability
---
apiVersion: v1
kind: Pod
metadata:
  name: probes-pod
  namespace: observability
spec:
  containers:
  - name: nginx
    image: nginx
    resources:
      requests:
        cpu: 100m
        memory: 128Mi
      limits:
        cpu: 200m
        memory: 256Mi
    livenessProbe:
      httpGet:
        path: /healthz
        port: 80
      initialDelaySeconds: 10
      periodSeconds: 5
    readinessProbe:
      httpGet:
        path: /
        port: 80
      initialDelaySeconds: 5
      periodSeconds: 3
EOF
```

## Question 6: Services - Different Service Types

Create deployment with different service types:

```bash
# Create namespace
kubectl create namespace services

# Create deployment and three different services
cat <<EOF | kubectl apply -f -
apiVersion: v1
kind: Namespace
metadata:
  name: services
---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: web-app
  namespace: services
spec:
  replicas: 3
  selector:
    matchLabels:
      app: web
  template:
    metadata:
      labels:
        app: web
    spec:
      containers:
      - name: nginx
        image: nginx:alpine
        ports:
        - containerPort: 80
---
apiVersion: v1
kind: Service
metadata:
  name: web-svc-cluster
  namespace: services
spec:
  selector:
    app: web
  ports:
  - port: 80
    targetPort: 80
  type: ClusterIP
---
apiVersion: v1
kind: Service
metadata:
  name: web-svc-nodeport
  namespace: services
spec:
  selector:
    app: web
  ports:
  - port: 80
    targetPort: 80
    nodePort: 30080
  type: NodePort
---
apiVersion: v1
kind: Service
metadata:
  name: web-svc-lb
  namespace: services
spec:
  selector:
    app: web
  ports:
  - port: 80
    targetPort: 80
  type: LoadBalancer
EOF
```

## Question 7: State - PV, PVC, and StatefulApp

Set up persistent storage for MySQL:

```bash
# Create namespace
kubectl create namespace state

# Create PV, PVC, and MySQL pod
cat <<EOF | kubectl apply -f -
apiVersion: v1
kind: Namespace
metadata:
  name: state
---
apiVersion: v1
kind: PersistentVolume
metadata:
  name: db-pv
spec:
  capacity:
    storage: 1Gi
  accessModes:
    - ReadWriteOnce
  persistentVolumeReclaimPolicy: Retain
  hostPath:
    path: /mnt/data
---
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: db-pvc
  namespace: state
spec:
  accessModes:
    - ReadWriteOnce
  resources:
    requests:
      storage: 500Mi
---
apiVersion: v1
kind: Pod
metadata:
  name: db-pod
  namespace: state
spec:
  containers:
  - name: mysql
    image: mysql:5.7
    env:
    - name: MYSQL_ROOT_PASSWORD
      value: rootpassword
    - name: MYSQL_DATABASE
      value: mydb
    - name: MYSQL_USER
      value: myuser
    - name: MYSQL_PASSWORD
      value: mypassword
    volumeMounts:
    - name: mysql-storage
      mountPath: /var/lib/mysql
  volumes:
  - name: mysql-storage
    persistentVolumeClaim:
      claimName: db-pvc
EOF
```

## Question 8: Pod Design - CronJob

Create a CronJob:

```bash
# Ensure namespace exists (should be created from Question 3)
kubectl get namespace pod-design || kubectl create namespace pod-design

# Create CronJob
cat <<EOF | kubectl apply -f -
apiVersion: batch/v1
kind: CronJob
metadata:
  name: backup-job
  namespace: pod-design
spec:
  schedule: "*/5 * * * *"
  jobTemplate:
    spec:
      activeDeadlineSeconds: 100
      template:
        spec:
          containers:
          - name: backup
            image: busybox
            command: ['sh', '-c', 'echo Backup started: $(date); sleep 30; echo Backup completed: $(date)']
          restartPolicy: OnFailure
EOF
```

## Question 9: Troubleshooting a Deployment

Fix a broken deployment (assuming it's already created but not working):

```bash
# First check what's wrong with the deployment
kubectl describe deployment broken-deployment -n troubleshooting

# Common fixes might include:

# Fix 1: Correct the image if it's incorrect
kubectl set image deployment/broken-deployment nginx=nginx:1.19 -n troubleshooting

# Fix 2: If resource requests are too high
kubectl patch deployment broken-deployment -n troubleshooting --patch '{"spec":{"template":{"spec":{"containers":[{"name":"nginx","resources":{"requests":{"cpu":"100m","memory":"128Mi"},"limits":{"cpu":"200m","memory":"256Mi"}}}]}}}}'

# Fix 3: If there's a configuration issue in the pod template
kubectl edit deployment broken-deployment -n troubleshooting

# Fix 4: If a network policy is blocking traffic
kubectl get networkpolicies -n troubleshooting
kubectl delete networkpolicy restrictive-policy -n troubleshooting

# Verify the fix
kubectl rollout status deployment/broken-deployment -n troubleshooting
```

## Question 10: Networking - NetworkPolicy

Create pods and a NetworkPolicy:

```bash
# Create namespace
kubectl create namespace networking

# Create the three pods
cat <<EOF | kubectl apply -f -
apiVersion: v1
kind: Namespace
metadata:
  name: networking
---
apiVersion: v1
kind: Pod
metadata:
  name: secure-db
  namespace: networking
  labels:
    app: db
spec:
  containers:
  - name: postgres
    image: postgres:12
    env:
    - name: POSTGRES_PASSWORD
      value: password
---
apiVersion: v1
kind: Pod
metadata:
  name: frontend
  namespace: networking
  labels:
    role: frontend
spec:
  containers:
  - name: nginx
    image: nginx
---
apiVersion: v1
kind: Pod
metadata:
  name: monitoring
  namespace: networking
  labels:
    role: monitoring
spec:
  containers:
  - name: nginx
    image: nginx
---
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: db-network-policy
  namespace: networking
spec:
  podSelector:
    matchLabels:
      app: db
  policyTypes:
  - Ingress
  - Egress
  ingress:
  - from:
    - podSelector:
        matchLabels:
          role: frontend
    ports:
    - protocol: TCP
      port: 5432
  egress:
  - to:
    - podSelector:
        matchLabels:
          role: monitoring
    ports:
    - protocol: TCP
      port: 8080
EOF
```

## Question 19: Pod Networking

### Task:
Create a pod with specific networking configurations:

1. Create a namespace called `pod-networking`
2. Create a pod named `network-pod` in the `pod-networking` namespace with the image `nginx:alpine`
3. Configure the pod with the following:
   - Hostname set to `custom-host`
   - Subdomain set to `example`
   - DNS Policy set to `ClusterFirstWithHostNet`
   - Add custom DNS configuration:
     - Nameservers: `8.8.8.8` and `8.8.4.4`
     - Searches: `example.com`

### Solution:

First, create the namespace:

```bash
kubectl create namespace pod-networking
```

Then, create a YAML file for the pod with the required networking configurations:

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: network-pod
  namespace: pod-networking
spec:
  hostname: custom-host
  subdomain: example
  dnsPolicy: ClusterFirstWithHostNet
  dnsConfig:
    nameservers:
    - 8.8.8.8
    - 8.8.4.4
    searches:
    - example.com
  containers:
  - name: nginx
    image: nginx:alpine
```

Apply the YAML file:

```bash
kubectl apply -f network-pod.yaml
```

Verify the pod is running:

```bash
kubectl get pod -n pod-networking
```

## Question 20: Network Policies

### Task:
Create network policies to control traffic between pods:

1. Create a namespace called `network-policy`
2. Create three pods in the namespace:
   - A pod named `web` with image `nginx` and label `app=web`
   - A pod named `db` with image `postgres` and label `app=db`
   - A pod named `cache` with image `redis` and label `app=cache`
3. Create a network policy named `db-policy` that allows only the `web` pod to access the `db` pod on port 5432
4. Create a network policy named `cache-policy` that allows only the `web` pod to access the `cache` pod on port 6379
5. Create a default deny policy named `default-deny` that blocks all other traffic within the namespace

### Solution:

First, create the namespace:

```bash
kubectl create namespace network-policy
```

Create the three pods:

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: web
  namespace: network-policy
  labels:
    app: web
spec:
  containers:
  - name: nginx
    image: nginx
---
apiVersion: v1
kind: Pod
metadata:
  name: db
  namespace: network-policy
  labels:
    app: db
spec:
  containers:
  - name: postgres
    image: postgres
    env:
    - name: POSTGRES_PASSWORD
      value: "password"
---
apiVersion: v1
kind: Pod
metadata:
  name: cache
  namespace: network-policy
  labels:
    app: cache
spec:
  containers:
  - name: redis
    image: redis
```

Save this as `pods.yaml` and apply it:

```bash
kubectl apply -f pods.yaml
```

Create the DB network policy:

```yaml
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: db-policy
  namespace: network-policy
spec:
  podSelector:
    matchLabels:
      app: db
  policyTypes:
  - Ingress
  ingress:
  - from:
    - podSelector:
        matchLabels:
          app: web
    ports:
    - port: 5432
```

Create the cache network policy:

```yaml
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: cache-policy
  namespace: network-policy
spec:
  podSelector:
    matchLabels:
      app: cache
  policyTypes:
  - Ingress
  ingress:
  - from:
    - podSelector:
        matchLabels:
          app: web
    ports:
    - port: 6379
```

Create the default deny policy:

```yaml
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: default-deny
  namespace: network-policy
spec:
  podSelector: {}
  policyTypes:
  - Ingress
```

Save these as separate files or in one file with `---` separators, and apply them:

```bash
kubectl apply -f network-policies.yaml
```

Verify the network policies are applied:

```bash
kubectl get networkpolicy -n network-policy
``` 