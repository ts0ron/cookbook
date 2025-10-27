# Kubernetes Deployment Guide for Cookbook

This guide will help you deploy the Cookbook application to Kubernetes.

## Prerequisites

- Kubernetes cluster (minikube, kind, or cloud provider)
- kubectl configured
- Docker images pushed to your repository

## Deployment Steps

### 1. Enable Ingress (if using minikube or kind)

If you're using **minikube**:
```bash
minikube addons enable ingress
```

If you're using **kind**:
```bash
# Install nginx ingress controller
kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/main/deploy/static/provider/kind/deploy.yaml
```

If you're using a cloud provider (AWS, GCP, Azure), the ingress controller is typically pre-installed.

### 2. Verify Ingress Controller is Running

```bash
kubectl get pods -n ingress-nginx
```

### 3. Get Ingress IP Address

For **minikube**:
```bash
minikube ip
```

For **cloud providers**, get the external IP:
```bash
kubectl get ingress -n cookbook
```

### 4. Deploy the Application

Deploy all resources to the cluster:
```bash
cd deployment/k8s
kubectl apply -f namespace.yaml
kubectl apply -f config-and-secrets.yaml
kubectl apply -f mongo.yaml
kubectl apply -f backend.yaml
kubectl apply -f frontend.yaml
kubectl apply -f ingress.yaml
```

Or apply all at once:
```bash
kubectl apply -f .
```

### 5. Wait for Pods to be Ready

```bash
kubectl get pods -n cookbook
```

Wait until all pods show `Running` status:
```bash
kubectl wait --for=condition=ready pod -l app=backend -n cookbook --timeout=90s
kubectl wait --for=condition=ready pod -l app=frontend -n cookbook --timeout=90s
```

### 6. Access the Application

#### Option A: Direct Access (minikube/kind)

For **minikube**, add to `/etc/hosts` (or equivalent):
```
<INGRESS_IP>  localhost
```

Then access:
- Frontend: `http://localhost`
- Backend API: `http://localhost/api/hello/world`

#### Option B: Direct Service Access (LoadBalancer)

Services are exposed via LoadBalancer:
- Frontend: `http://localhost:3000`
- Backend API: `http://localhost:8014/hello/world`

To find the exact ports:
```bash
kubectl get svc -n cookbook
```

#### Option C: Port Forwarding (any cluster)

```bash
# Start port forwarding
kubectl port-forward -n cookbook svc/frontend-service 8080:3000
kubectl port-forward -n cookbook svc/backend-service 8014:8014
```

Then access:
- Frontend: `http://localhost:8080`
- Backend API: `http://localhost:8014/hello/world`

#### Option D: Using Ingress with Forwarding

If you have ingress set up but it's not accessible from your machine:

```bash
# Forward traffic from your machine to the ingress controller
kubectl port-forward -n ingress-nginx svc/ingress-nginx-controller 80:80
```

### 7. Verify Deployment

Check service endpoints:
```bash
kubectl get svc -n cookbook
```

Check ingress:
```bash
kubectl get ingress -n cookbook
```

Check pod logs (if needed):
```bash
kubectl logs -n cookbook -l app=backend
kubectl logs -n cookbook -l app=frontend
```

## Routes

- **Frontend**: Available at `/` (root path)
- **Backend API**: Available at `/api/*` paths
  - Example: `/api/hello/world` → backend `/hello/world`

## Troubleshooting

### Check pod status
```bash
kubectl describe pod <pod-name> -n cookbook
```

### Check service endpoints
```bash
kubectl get endpoints -n cookbook
```

### Check ingress status
```bash
kubectl describe ingress cookbook-ingress -n cookbook
```

### View all resources
```bash
kubectl get all -n cookbook
```

### Clean up (if needed)
```bash
kubectl delete namespace cookbook
```

