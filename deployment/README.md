# Cookbook - Deployment Guide

This directory contains Kubernetes deployment configurations and scripts for the Cookbook application.

## Contents

- `k8s/` - Kubernetes manifest files
  - `namespace.yaml` - Namespace configuration
  - `config-and-secrets.yaml` - ConfigMaps and Secrets
  - `mongo.yaml` - MongoDB deployment
  - `backend.yaml` - Backend service deployment
  - `frontend.yaml` - Frontend service deployment
  - `ingress.yaml` - Ingress controller configuration
- `deploy.sh` - Automated deployment script
- `manage-access.sh` - Access management script
- `DEPLOYMENT.md` - Detailed deployment documentation
- `ACCESS.md` - Access management documentation

## Prerequisites

Before deploying, ensure you have:

1. **Kubernetes Cluster**
   - Local: minikube, kind, or Docker Desktop
   - Cloud: EKS (AWS), GKE (GCP), AKS (Azure), or other

2. **kubectl** configured and connected to your cluster

3. **Docker Images** built and pushed to your registry
   ```bash
   # Build and push backend image
   cd backend
   docker build -t <registry>/cookbook-backend:latest .
   docker push <registry>/cookbook-backend:latest
   
   # Build and push frontend image
   cd frontend
   docker build -t <registry>/cookbook-frontend:latest .
   docker push <registry>/cookbook-frontend:latest
   ```

## Quick Deployment

### Automated Deployment

For the easiest deployment experience, use the automated script:

```bash
cd deployment
./deploy.sh
```

This script will:
1. Apply all Kubernetes manifests in order
2. Wait for pods to be ready
3. Automatically set up access (minikube tunnel or port-forwarding)
4. Display access URLs

### Manual Deployment

If you prefer manual control:

```bash
cd deployment/k8s

# Apply all resources
kubectl apply -f namespace.yaml
kubectl apply -f config-and-secrets.yaml
kubectl apply -f mongo.yaml
kubectl apply -f backend.yaml
kubectl apply -f frontend.yaml
kubectl apply -f ingress.yaml

# Wait for pods
kubectl wait --for=condition=ready pod -l app=backend -n cookbook --timeout=120s
kubectl wait --for=condition=ready pod -l app=frontend -n cookbook --timeout=120s
```

## Access Methods

After deployment, you can access the services through multiple methods. See `ACCESS.md` for detailed instructions on:
- Minikube tunnel setup
- Port-forwarding
- LoadBalancer services
- Ingress configuration

## Managing Access

Use the `manage-access.sh` script to easily start/stop access to your services:

```bash
# Start access
./manage-access.sh start

# Stop access
./manage-access.sh stop

# Check status
./manage-access.sh status
```

## Configuration

### Update Docker Images

Before deploying, update the Docker image references in the manifest files:

**backend.yaml:**
```yaml
image: <your-registry>/cookbook-backend:latest
```

**frontend.yaml:**
```yaml
image: <your-registry>/cookbook-frontend:latest
```

### Environment Variables

Configuration is managed through ConfigMaps and Secrets in `config-and-secrets.yaml`. Update these values as needed:

```bash
kubectl edit configmap backend-config -n cookbook
kubectl edit secret backend-secrets -n cookbook
```

## Verification

### Check Deployment Status

```bash
# View all resources
kubectl get all -n cookbook

# Check pod logs
kubectl logs -n cookbook -l app=backend
kubectl logs -n cookbook -l app=frontend
```

### Test Endpoints

```bash
# Test backend health
curl http://localhost:3001/health

# Test backend API
curl http://localhost:3001/hello/world

# Access frontend
curl http://localhost:3000
```

## Troubleshooting

### Pods Not Starting

```bash
# Check pod status
kubectl get pods -n cookbook

# Describe pod for details
kubectl describe pod <pod-name> -n cookbook

# View pod logs
kubectl logs <pod-name> -n cookbook
```

### Service Not Accessible

```bash
# Check service endpoints
kubectl get svc -n cookbook
kubectl get endpoints -n cookbook

# Check ingress
kubectl get ingress -n cookbook
kubectl describe ingress -n cookbook
```

### Image Pull Errors

```bash
# Check if images exist
docker images | grep cookbook

# Verify registry authentication
kubectl get secret <registry-secret> -n cookbook
```

## Cleanup

To remove all deployed resources:

```bash
# Delete namespace (removes everything in the namespace)
kubectl delete namespace cookbook

# Or delete individual resources
cd deployment/k8s
kubectl delete -f .
```

## Advanced Configuration

### Customizing Resources

Edit the manifest files directly:
- `backend.yaml` - Adjust replicas, resources, ports
- `frontend.yaml` - Adjust replicas, resources
- `ingress.yaml` - Configure routing rules
- `mongo.yaml` - Configure MongoDB settings

### Persistent Storage

MongoDB uses persistent volumes. To configure storage:
```bash
kubectl get pv
kubectl get pvc -n cookbook
```

### Scaling

Scale services as needed:

```bash
# Scale backend
kubectl scale deployment backend -n cookbook --replicas=3

# Scale frontend
kubectl scale deployment frontend -n cookbook --replicas=2
```

## Documentation

For more detailed information, see:
- [DEPLOYMENT.md](./DEPLOYMENT.md) - Complete deployment guide
- [ACCESS.md](./ACCESS.md) - Access management details
- [Kubernetes Documentation](https://kubernetes.io/docs/)

## Support

For issues with:
- **Backend deployment**: Check `kubectl logs -n cookbook -l app=backend`
- **Frontend deployment**: Check `kubectl logs -n cookbook -l app=frontend`
- **MongoDB**: Check `kubectl logs -n cookbook -l app=mongo`
- **Ingress**: Check `kubectl get ingress -n cookbook`

