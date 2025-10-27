# How to Access Your Cookbook Application

## Setup

Your services are running in Kubernetes. There are two ways to access them on minikube:

### Option 1: Using `minikube tunnel` (Recommended for LoadBalancer)

Run this in a separate terminal:
```bash
minikube tunnel
```

This will expose all LoadBalancer services on localhost automatically.

Then access:
- **Frontend**: http://localhost:3000
- **Backend API**: http://localhost:8014/hello/world

### Option 2: Using Port Forwarding

Run these commands:
```bash
# Frontend on port 3000
kubectl port-forward -n cookbook svc/frontend-lb 3000:3000

# Backend on port 8014 (in another terminal)
kubectl port-forward -n cookbook svc/backend-lb 8014:8014
```

Then access:
- **Frontend**: http://localhost:3000
- **Backend API**: http://localhost:8014/hello/world

### Option 3: Via Ingress

If you have ingress enabled:
```bash
# Enable ingress first
minikube addons enable ingress

# Get the ingress IP
INGRESS_IP=$(minikube ip)

# Add to /etc/hosts (or equivalent)
echo "$INGRESS_IP  localhost" | sudo tee -a /etc/hosts

# Forward ingress to localhost:80
kubectl port-forward -n ingress-nginx svc/ingress-nginx-controller 80:80
```

Then access:
- **Frontend**: http://localhost/
- **Backend API**: http://localhost/api/hello/world

## Current Services

```bash
# View all services
kubectl get svc -n cookbook
```

Expected output:
- `frontend-lb` - LoadBalancer on port 3000
- `backend-lb` - LoadBalancer on port 8014
- `frontend-service` - ClusterIP on port 80 (for ingress)
- `backend-service` - ClusterIP on port 8014 (for ingress)

## Troubleshooting

If port forwarding isn't working:
```bash
# Check if services exist
kubectl get svc -n cookbook

# Check pods are running
kubectl get pods -n cookbook

# Check logs
kubectl logs -n cookbook -l app=frontend
kubectl logs -n cookbook -l app=backend
```

