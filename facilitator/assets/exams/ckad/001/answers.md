# CKAD Practice Exam - Answers

## Question 1: Create a deployment called nginx-deployment in the namespace dev with 3 replicas and image nginx:latest

```bash
# Create the namespace if it doesn't exist
kubectl create namespace dev

# Create the deployment with 3 replicas
kubectl create deployment nginx-deployment -n dev --image=nginx:latest --replicas=3
```

## Question 2: Create a PersistentVolume named 'pv-storage' with 1Gi capacity, access mode ReadWriteOnce, hostPath type at /mnt/data, and reclaim policy Retain

```yaml
apiVersion: v1
kind: PersistentVolume
metadata:
  name: pv-storage
spec:
  capacity:
    storage: 1Gi
  accessModes:
    - ReadWriteOnce
  persistentVolumeReclaimPolicy: Retain
  hostPath:
    path: /mnt/data
```

Save this as `pv-storage.yaml` and apply:

```bash
kubectl apply -f pv-storage.yaml
```

## Question 3: Create a StorageClass named 'fast-storage' with provisioner 'kubernetes.io/no-provisioner' and volumeBindingMode 'WaitForFirstConsumer'

```yaml
apiVersion: storage.k8s.io/v1
kind: StorageClass
metadata:
  name: fast-storage
provisioner: kubernetes.io/no-provisioner
volumeBindingMode: WaitForFirstConsumer
```

Save this as `storage-class.yaml` and apply:

```bash
kubectl apply -f storage-class.yaml
```

## Question 4: Create a PersistentVolumeClaim named 'pvc-app' that requests 500Mi of storage with ReadWriteOnce access mode and uses the 'fast-storage' StorageClass

```yaml
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: pvc-app
  namespace: storage-test
spec:
  accessModes:
    - ReadWriteOnce
  resources:
    requests:
      storage: 500Mi
  storageClassName: fast-storage
```

Save this as `pvc.yaml` and apply:

```bash
kubectl apply -f pvc.yaml -n storage-test
```

## Question 5: The deployment 'broken-app' in namespace 'troubleshooting' is failing to start. Identify and fix the issue

Troubleshooting steps:
```bash
# Check the pods in the troubleshooting namespace
kubectl get pods -n troubleshooting

# Check the pod details for errors
kubectl describe pod -l app=broken-app -n troubleshooting

# Check logs of the failing pod
kubectl logs <pod-name> -n troubleshooting
```

Potential fixes:
1. If the image is incorrect: 
   ```bash
   kubectl set image deployment/broken-app container-name=correct-image:tag -n troubleshooting
   ```
2. If environment variables are missing:
   ```bash
   kubectl edit deployment broken-app -n troubleshooting
   ```
3. If resource limits are too low:
   ```bash
   kubectl patch deployment broken-app -n troubleshooting -p '{"spec":{"template":{"spec":{"containers":[{"name":"container-name","resources":{"limits":{"memory":"512Mi"}}}]}}}}'
   ```

## Question 6: The kubelet on node 'worker-1' is not functioning properly. Diagnose and fix the issue

Troubleshooting steps:
```bash
# Check node status
kubectl get nodes

# Describe the node for more information
kubectl describe node worker-1

# SSH into the worker node
ssh worker-1

# Check kubelet status
systemctl status kubelet

# Check kubelet logs
journalctl -u kubelet -n 100

# Restart kubelet if needed
systemctl restart kubelet

# Check kubelet configuration
cat /var/lib/kubelet/config.yaml
```

Common kubelet issues:
1. Service not running: `systemctl start kubelet`
2. Configuration errors: Edit `/var/lib/kubelet/config.yaml`
3. Certificate issues: Renew certificates if needed
4. Disk space issues: `df -h` to check and clean up if needed

## Question 7: Service 'web-service' in namespace 'troubleshooting' is not routing traffic to pods properly. Identify and fix the issue

Troubleshooting steps:
```bash
# Check the service
kubectl get svc web-service -n troubleshooting

# Describe the service to check selector labels
kubectl describe svc web-service -n troubleshooting

# Check if there are pods matching the selector
kubectl get pods -l <service-selector-label> -n troubleshooting
```

Common fixes:
1. Fix service selector to match pod labels:
   ```bash
   kubectl edit svc web-service -n troubleshooting
   ```
2. Fix pod labels to match service selector:
   ```bash
   kubectl label pods <pod-name> key=value -n troubleshooting
   ```
3. Fix service port mapping:
   ```bash
   kubectl edit svc web-service -n troubleshooting
   ```

## Question 8: Pod 'logging-pod' in namespace 'troubleshooting' is experiencing high CPU usage. Identify the container causing the issue and take appropriate action to limit its CPU usage

```bash
# Check current resource usage
kubectl top pod logging-pod -n troubleshooting
kubectl top pod logging-pod -n troubleshooting --containers

# Add CPU limits to the container
kubectl patch pod logging-pod -n troubleshooting -p '{"spec":{"containers":[{"name":"<container-name>","resources":{"limits":{"cpu":"200m"}}}]}}'
```

Or edit the deployment if the pod is managed by one:
```bash
kubectl edit deployment <deployment-name> -n troubleshooting
```

Add the following to the container spec:
```yaml
resources:
  limits:
    cpu: 200m
  requests:
    cpu: 100m
```

## Question 9: Create a ConfigMap named 'app-config' in namespace 'workloads' containing the following key-value pairs: APP_ENV=production, LOG_LEVEL=info. Then create a Pod named 'config-pod' using 'nginx' image that mounts these configurations as environment variables

```bash
# Create the ConfigMap
kubectl create configmap app-config -n workloads --from-literal=APP_ENV=production --from-literal=LOG_LEVEL=info
```

Create the Pod with ConfigMap environment variables:
```yaml
apiVersion: v1
kind: Pod
metadata:
  name: config-pod
  namespace: workloads
spec:
  containers:
  - name: nginx
    image: nginx
    env:
    - name: APP_ENV
      valueFrom:
        configMapKeyRef:
          name: app-config
          key: APP_ENV
    - name: LOG_LEVEL
      valueFrom:
        configMapKeyRef:
          name: app-config
          key: LOG_LEVEL
```

Save as `config-pod.yaml` and apply:
```bash
kubectl apply -f config-pod.yaml
```

## Question 10: Create a Secret named 'db-credentials' in namespace 'workloads' containing username=admin and password=securepass. Then create a Pod named 'secure-pod' using 'mysql:5.7' image with these credentials set as environment variables DB_USER and DB_PASSWORD

```bash
# Create the Secret
kubectl create secret generic db-credentials -n workloads --from-literal=username=admin --from-literal=password=securepass
```

Create the Pod with Secret environment variables:
```yaml
apiVersion: v1
kind: Pod
metadata:
  name: secure-pod
  namespace: workloads
spec:
  containers:
  - name: mysql
    image: mysql:5.7
    env:
    - name: DB_USER
      valueFrom:
        secretKeyRef:
          name: db-credentials
          key: username
    - name: DB_PASSWORD
      valueFrom:
        secretKeyRef:
          name: db-credentials
          key: password
    - name: MYSQL_ROOT_PASSWORD
      valueFrom:
        secretKeyRef:
          name: db-credentials
          key: password
```

Save as `secure-pod.yaml` and apply:
```bash
kubectl apply -f secure-pod.yaml
```

## Question 11: Create a Horizontal Pod Autoscaler for the deployment 'web-app' in namespace 'workloads' that scales between 2 and 6 replicas based on 70% CPU utilization

```bash
# Create the HPA
kubectl autoscale deployment web-app -n workloads --min=2 --max=6 --cpu-percent=70
```

Or using YAML:
```yaml
apiVersion: autoscaling/v2
kind: HorizontalPodAutoscaler
metadata:
  name: web-app
  namespace: workloads
spec:
  scaleTargetRef:
    apiVersion: apps/v1
    kind: Deployment
    name: web-app
  minReplicas: 2
  maxReplicas: 6
  metrics:
  - type: Resource
    resource:
      name: cpu
      target:
        type: Utilization
        averageUtilization: 70
```

Save as `hpa.yaml` and apply:
```bash
kubectl apply -f hpa.yaml
```

## Question 12: Create a Pod named 'health-pod' in namespace 'workloads' using 'nginx' image with a liveness probe that checks the path /healthz on port 80 every 15 seconds, and a readiness probe that checks port 80 every 10 seconds

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: health-pod
  namespace: workloads
spec:
  containers:
  - name: nginx
    image: nginx
    ports:
    - containerPort: 80
    livenessProbe:
      httpGet:
        path: /healthz
        port: 80
      initialDelaySeconds: 30
      periodSeconds: 15
    readinessProbe:
      tcpSocket:
        port: 80
      initialDelaySeconds: 5
      periodSeconds: 10
```

Save as `health-pod.yaml` and apply:
```bash
kubectl apply -f health-pod.yaml
```

## Question 13: Create a ClusterRole named 'pod-reader' that allows getting, watching, and listing pods. Then create a ClusterRoleBinding named 'read-pods' that grants this role to the user 'jane' in the namespace 'cluster-admin'

```bash
# Create the ClusterRole
kubectl create clusterrole pod-reader --verb=get,watch,list --resource=pods
```

Or using YAML:
```yaml
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRole
metadata:
  name: pod-reader
rules:
- apiGroups: [""]
  resources: ["pods"]
  verbs: ["get", "watch", "list"]
```

Create the ClusterRoleBinding:
```bash
kubectl create clusterrolebinding read-pods --clusterrole=pod-reader --user=jane --namespace=cluster-admin
```

Or using YAML:
```yaml
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRoleBinding
metadata:
  name: read-pods
subjects:
- kind: User
  name: jane
  apiGroup: rbac.authorization.k8s.io
roleRef:
  kind: ClusterRole
  name: pod-reader
  apiGroup: rbac.authorization.k8s.io
```

Save YAML files and apply them:
```bash
kubectl apply -f cluster-role.yaml
kubectl apply -f cluster-role-binding.yaml
```

## Question 14: Install Helm and use it to deploy the Prometheus monitoring stack in the 'monitoring' namespace

```bash
# Install Helm
curl https://raw.githubusercontent.com/helm/helm/master/scripts/get-helm-3 | bash

# Create the namespace
kubectl create namespace monitoring

# Add Prometheus repo
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm repo update

# Install Prometheus stack
helm install prometheus prometheus-community/kube-prometheus-stack --namespace monitoring
```

## Question 15: Create a CRD (CustomResourceDefinition) for a new resource type 'Backup' in API group 'data.example.com' with version 'v1alpha1' that includes fields 'spec.source' and 'spec.destination'

```yaml
apiVersion: apiextensions.k8s.io/v1
kind: CustomResourceDefinition
metadata:
  name: backups.data.example.com
spec:
  group: data.example.com
  names:
    kind: Backup
    listKind: BackupList
    plural: backups
    singular: backup
  scope: Namespaced
  versions:
  - name: v1alpha1
    served: true
    storage: true
    schema:
      openAPIV3Schema:
        type: object
        properties:
          spec:
            type: object
            properties:
              source:
                type: string
              destination:
                type: string
            required: ["source", "destination"]
```

Save as `backup-crd.yaml` and apply:
```bash
kubectl apply -f backup-crd.yaml
```

## Question 16: Create a NetworkPolicy named 'allow-traffic' in namespace 'networking' that allows traffic to pods with label 'app=web' only from pods with label 'tier=frontend' on port 80

```yaml
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: allow-traffic
  namespace: networking
spec:
  podSelector:
    matchLabels:
      app: web
  ingress:
  - from:
    - podSelector:
        matchLabels:
          tier: frontend
    ports:
    - protocol: TCP
      port: 80
```

Save as `network-policy.yaml` and apply:
```bash
kubectl apply -f network-policy.yaml
```

## Question 17: Create a ClusterIP service named 'internal-app' in namespace 'networking' that routes traffic to pods with label 'app=backend' on port 8080, exposing the service on port 80

```bash
kubectl create service clusterip internal-app --tcp=80:8080 -n networking --selector=app=backend
```

Or using YAML:
```yaml
apiVersion: v1
kind: Service
metadata:
  name: internal-app
  namespace: networking
spec:
  type: ClusterIP
  selector:
    app: backend
  ports:
  - port: 80
    targetPort: 8080
    protocol: TCP
```

Save as `internal-service.yaml` and apply:
```bash
kubectl apply -f internal-service.yaml
```

## Question 18: Create a LoadBalancer service named 'public-web' in namespace 'networking' that exposes port 80 for the deployment 'web-frontend'

```bash
kubectl expose deployment web-frontend --type=LoadBalancer --port=80 --name=public-web -n networking
```

Or using YAML:
```yaml
apiVersion: v1
kind: Service
metadata:
  name: public-web
  namespace: networking
spec:
  type: LoadBalancer
  selector:
    app: web-frontend
  ports:
  - port: 80
    targetPort: 80
    protocol: TCP
```

Save as `loadbalancer-service.yaml` and apply:
```bash
kubectl apply -f loadbalancer-service.yaml
```

## Question 19: Create an Ingress resource named 'api-ingress' in namespace 'networking' that routes traffic from 'api.example.com' to the service 'api-service' on port 80

```yaml
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: api-ingress
  namespace: networking
spec:
  rules:
  - host: api.example.com
    http:
      paths:
      - path: /
        pathType: Prefix
        backend:
          service:
            name: api-service
            port:
              number: 80
```

Save as `ingress.yaml` and apply:
```bash
kubectl apply -f ingress.yaml
```

## Question 20: Configure CoreDNS to add a custom entry that resolves 'database.local' to the IP address 10.96.0.20

```bash
# Edit the CoreDNS ConfigMap
kubectl edit configmap coredns -n kube-system
```

Add the following to the Corefile data:
```
hosts {
    10.96.0.20 database.local
    fallthrough
}
```

Restart CoreDNS pods:
```bash
kubectl delete pod -l k8s-app=kube-dns -n kube-system
```

Or create a custom ConfigMap with hosts entries and mount it in the CoreDNS deployment.
