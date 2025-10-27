# Cookbook - Development Setup Guide

This guide will help you set up and run the Cookbook application in a Kubernetes development environment using minikube.

## Project Overview

Cookbook is a full-stack web application consisting of:
- **Backend**: Express.js server with TypeScript
- **Frontend**: React application with Vite
- **Deployment**: Kubernetes configurations

## Environment Variables Configuration

The application uses environment variables for configuration. Copy the example file and modify as needed:

```bash
cp .env.example .env
```

### Available Variables

- `FRONTEND_PORT`: Port for the frontend dev server (default: 3000)
- `BACKEND_PORT`: Port for the backend server (default: 8014)
- `VITE_API_BASE_URL`: API base URL for frontend proxy (default: http://localhost:8014)
- `NODE_ENV`: Environment mode (default: development)

## Quick Start with Development Scripts

### Individual Services

Start frontend only:
```bash
cd frontend
npm run dev
```

Start backend only:
```bash
cd backend
npm run dev
```

### Both Services Together

From the project root, start both services:
```bash
./dev.sh
```

This will:
- Load environment variables from `.env` (if it exists)
- Set sensible defaults if variables are not set
- Start both frontend and backend in the background
- Display access URLs

## Manual Development (Without Scripts)

If you prefer to run services manually:

### Frontend
```bash
cd frontend
FRONTEND_PORT=3000 VITE_API_BASE_URL=http://localhost:8014 npx vite
```

### Backend
```bash
cd backend
BACKEND_PORT=8014 NODE_ENV=development npx ts-node-dev --respawn --transpile-only server.ts
```

## Prerequisites

Before you begin, ensure you have the following installed:

### Required Tools

- **Docker** - [Download](https://www.docker.com/products/docker-desktop) (for building images)
- **Minikube** - [Installation Guide](https://minikube.sigs.k8s.io/docs/start/) (for local Kubernetes cluster)
- **kubectl** - [Installation Guide](https://kubernetes.io/docs/tasks/tools/) (Kubernetes command-line tool)
- **Node.js** (v18 or higher) - [Download](https://nodejs.org/) (for local development alternative)

## Quick Start with Development Scripts

### Individual Services

Start frontend only:
```bash
cd frontend
npm run dev
```

Start backend only:
```bash
cd backend
npm run dev
```

### Both Services Together

From the project root, start both services:
```bash
./dev.sh
```

This will:
- Load environment variables from `.env` (if it exists)
- Set sensible defaults if variables are not set
- Start both frontend and backend in the background
- Display access URLs

## Manual Development (Without Scripts)

If you prefer to run services manually:

### Frontend
```bash
cd frontend
FRONTEND_PORT=3000 VITE_API_BASE_URL=http://localhost:8014 npx vite
```

### Backend
```bash
cd backend
BACKEND_PORT=8014 NODE_ENV=development npx ts-node-dev --respawn --transpile-only server.ts
```

## Quick Start with Kubernetes (minikube)

This section covers the primary development workflow using minikube for a production-like environment.

### 1. Clone the Repository

```bash
git clone <repository-url>
cd cookbook
```

### 2. Start Minikube

```bash
# Start minikube cluster
minikube start

# Enable ingress addon (required for Ingress resources)
minikube addons enable ingress

# Verify minikube is running
kubectl cluster-info

# Set minikube's Docker daemon for building images
eval $(minikube docker-env)
```

### 3. Build and Deploy

Build the Docker images and deploy everything with one command:

```bash
# Build backend image (matches Kubernetes manifest)
cd backend
docker build -t r0nts/cookbook-backend:latest .
cd ..

# Build frontend image (matches Kubernetes manifest)
cd frontend
docker build -t r0nts/cookbook-frontend:latest .
cd ..

# Deploy to minikube using the deployment script
cd deployment
./deploy.sh

# Configure to use local images instead of pulling from registry
kubectl patch deployment backend -n cookbook -p '{"spec":{"template":{"spec":{"containers":[{"name":"backend","imagePullPolicy":"Never"}]}}}}'
kubectl patch deployment frontend -n cookbook -p '{"spec":{"template":{"spec":{"containers":[{"name":"frontend","imagePullPolicy":"Never"}]}}}}'
```

The `./deploy.sh` script will:
- Apply all Kubernetes manifests from `deployment/k8s/`
- Wait for pods to be ready
- Set up access via minikube tunnel or port-forwarding
- Display access URLs

**Alternative: Manual Deployment**

If you prefer to deploy manually instead of using the script:

```bash
cd deployment/k8s

# Apply all resources
kubectl apply -f namespace.yaml
kubectl apply -f config-and-secrets.yaml
kubectl apply -f mongo.yaml
kubectl apply -f backend.yaml
kubectl apply -f frontend.yaml
kubectl apply -f ingress.yaml

# Set image pull policy to Never (use local images)
kubectl patch deployment backend -n cookbook -p '{"spec":{"template":{"spec":{"containers":[{"name":"backend","imagePullPolicy":"Never"}]}}}}'
kubectl patch deployment frontend -n cookbook -p '{"spec":{"template":{"spec":{"containers":[{"name":"frontend","imagePullPolicy":"Never"}]}}}}'

# Wait for pods to be ready
kubectl wait --for=condition=ready pod -l app=backend -n cookbook --timeout=120s
kubectl wait --for=condition=ready pod -l app=frontend -n cookbook --timeout=120s
```

### 6. Access the Application

The deployment script automatically sets up access via minikube tunnel. You can access:

- **Frontend**: http://localhost:3000
- **Backend API**: http://localhost:8014/hello/world
- **Health Check**: http://localhost:8014/health

If the automatic setup didn't work, set up minikube tunnel manually in a separate terminal:

```bash
# This will run in the foreground, keep this terminal open
minikube tunnel
```

Or use port-forwarding:

```bash
# Terminal 1 - Frontend
kubectl port-forward -n cookbook svc/frontend-lb 3000:3000

# Terminal 2 - Backend
kubectl port-forward -n cookbook svc/backend-lb 8014:8014
```

### 7. Verify Deployment

Check the status of your pods:

```bash
kubectl get all -n cookbook
```

View logs:

```bash
# Backend logs
kubectl logs -n cookbook -l app=backend

# Frontend logs
kubectl logs -n cookbook -l app=frontend

# MongoDB logs
kubectl logs -n cookbook -l app=mongo
```

## Development Workflow

### Iterating on Code Changes

When developing with Kubernetes, you'll follow this workflow:

#### 1. Make Code Changes

Edit your source files in the `backend/` or `frontend/` directories as usual.

#### 2. Rebuild Docker Images

After making changes, rebuild the affected images:

```bash
# Set minikube's Docker daemon (if not already set)
eval $(minikube docker-env)

# Rebuild backend
cd backend
docker build -t r0nts/cookbook-backend:latest .
cd ..

# Rebuild frontend
cd frontend
docker build -t r0nts/cookbook-frontend:latest .
cd ..

cd ..
```

#### 3. Restart Pods

Restart the pods to use the new images:

```bash
# Restart backend pods
kubectl rollout restart deployment backend -n cookbook

# Restart frontend pods
kubectl rollout restart deployment frontend -n cookbook

# Watch the rollout
kubectl rollout status deployment/backend -n cookbook
kubectl rollout status deployment/frontend -n cookbook
```

#### 4. View Logs in Real-Time

Watch logs to see your changes take effect:

```bash
# Backend logs
kubectl logs -n cookbook -l app=backend -f

# Frontend logs
kubectl logs -n cookbook -l app=frontend -f
```

### Fast Iteration Helper Script

Create a helper script for faster iteration:

```bash
# Create deploy-dev.sh
cat > deploy-dev.sh << 'EOF'
#!/bin/bash
set -e

# Build backend
echo "Building backend..."
cd backend
docker build -t r0nts/cookbook-backend:latest . > /dev/null
cd ..

# Build frontend
echo "Building frontend..."
cd frontend
docker build -t r0nts/cookbook-frontend:latest . > /dev/null
cd ..

# Restart deployments
echo "Restarting pods..."
kubectl rollout restart deployment backend -n cookbook
kubectl rollout restart deployment frontend -n cookbook

echo "Waiting for rollout..."
kubectl rollout status deployment/backend -n cookbook --timeout=90s
kubectl rollout status deployment/frontend -n cookbook --timeout=90s

echo "✅ Deployment updated!"
EOF

chmod +x deploy-dev.sh
```

Then you can quickly deploy changes with:

```bash
./deploy-dev.sh
```

### Backend Endpoints

Once deployed, you can access:

- `GET http://localhost:8014/hello/world` - Hello World greeting
- `GET http://localhost:8014/health` - Health check endpoint

### Monitoring and Debugging

View pod status and health:

```bash
# Check all resources
kubectl get all -n cookbook

# Describe a specific pod
kubectl describe pod <pod-name> -n cookbook

# Execute into a pod (for debugging)
kubectl exec -it <pod-name> -n cookbook -- /bin/sh

# View resource usage
kubectl top pods -n cookbook
```

## Alternative: Local Development (Without Kubernetes)

If you prefer to develop without Kubernetes for faster iteration, you can use the traditional Node.js development workflow:

### Setup

1. **Install Dependencies**

```bash
# Backend
cd backend
npm install

# Frontend
cd ../frontend
npm install
```

2. **Start Services**

Open two terminal windows:

**Terminal 1 - Backend:**
```bash
cd backend
npm run dev
```
The backend will be available at http://localhost:8014

**Terminal 2 - Frontend:**
```bash
cd frontend
npm run dev
```
The frontend will be available at http://localhost:3000

### Available Scripts

**Backend:**
- `npm run dev` - Start in development mode with auto-reload
- `npm run build` - Build TypeScript to JavaScript
- `npm start` - Start the compiled JavaScript server
- `npm run dev:direct` - Start dev server directly (without env setup)

**Frontend:**
- `npm run dev` - Start development server with env setup
- `npm run build` - Build for production
- `npm run preview` - Preview production build
- `npm run lint` - Run ESLint
- `npm run dev:direct` - Start dev server directly (without env setup)

## Working with Docker Images

Both services include production-ready Dockerfiles with multi-stage builds.

### Understanding the Dockerfiles

**Backend Dockerfile** (`backend/Dockerfile`):
- Multi-stage build (builder + production)
- Only production dependencies in final image
- Includes health checks
- Exposes port 8014

**Frontend Dockerfile** (`frontend/Dockerfile`):
- Multi-stage build with Nginx
- Serves static files via Nginx
- Exposes port 3000

### Building for Different Environments

```bash
# Set Docker daemon context (important!)
eval $(minikube docker-env)

# Build for local development (matches Kubernetes manifests)
docker build -t r0nts/cookbook-backend:latest ./backend
docker build -t r0nts/cookbook-frontend:latest ./frontend

# Build for production (push to registry)
docker build -t your-registry/cookbook-backend:latest ./backend
docker build -t your-registry/cookbook-frontend:latest ./frontend
```

### Pushing Images to a Registry

For production deployments, push images to a container registry:

```bash
# Tag images
docker tag r0nts/cookbook-backend:latest your-registry/cookbook-backend:latest
docker tag r0nts/cookbook-frontend:latest your-registry/cookbook-frontend:latest

# Push to registry
docker push your-registry/cookbook-backend:latest
docker push your-registry/cookbook-frontend:latest
```

## Testing

### Backend Testing

```bash
# Test the health endpoint
curl http://localhost:8014/health

# Test the hello endpoint
curl http://localhost:8014/hello/world

# Test with name parameter
curl "http://localhost:8014/hello/world?name=John"
```

### Frontend Testing

1. Open the frontend at http://localhost:3000 in your browser
2. Enter a name in the input field
3. Click "Submit"
4. Verify the response from the backend is displayed

### Integration Testing with Kubernetes

```bash
# Test backend from within the cluster
kubectl run curl-test --image=curlimages/curl:latest -it --rm --restart=Never -- \
  curl http://backend-service:8014/hello/world

# Test MongoDB connectivity
kubectl exec -it deployment/mongo -n cookbook -- mongosh \
  --eval "db.version()"
```

## Troubleshooting

### Minikube Issues

**Minikube not starting:**
```bash
# Check minikube status
minikube status

# Start minikube
minikube start

# View logs
minikube logs

# Delete and recreate (if needed)
minikube delete
minikube start
```

**Docker daemon issues:**
```bash
# Check Docker daemon context
docker context ls

# Set minikube's Docker daemon
eval $(minikube docker-env)

# Verify you can build images
docker ps
```

### Pod Issues

**Pods not starting:**
```bash
# Check pod status
kubectl get pods -n cookbook

# Describe pod for details
kubectl describe pod <pod-name> -n cookbook

# View pod logs
kubectl logs <pod-name> -n cookbook

# View previous logs (if pod crashed)
kubectl logs <pod-name> -n cookbook --previous
```

**Image pull errors:**
```bash
# Check if images exist in minikube's Docker daemon
eval $(minikube docker-env)
docker images | grep cookbook

# Rebuild images
docker build -t r0nts/cookbook-backend:latest ./backend
docker build -t r0nts/cookbook-frontend:latest ./frontend

# Restart pods
kubectl rollout restart deployment backend -n cookbook
kubectl rollout restart deployment frontend -n cookbook
```

### Service Issues

**Services not accessible:**
```bash
# Check service status
kubectl get svc -n cookbook

# Check endpoints
kubectl get endpoints -n cookbook

# Test service internally
kubectl run curl-test --image=curlimages/curl:latest -it --rm --restart=Never -- \
  curl http://backend-service:8014/health
```

**Port conflicts:**
```bash
# Find process using port
lsof -i :3000
lsof -i :8014

# Kill existing port-forwards
pkill -f "kubectl port-forward"

# Kill minikube tunnel
sudo pkill -f "minikube tunnel"
```

### Minikube Tunnel Issues

**Tunnel not working:**
```bash
# Start tunnel in foreground to see errors
minikube tunnel

# Or use port-forwarding as alternative
kubectl port-forward -n cookbook svc/frontend-lb 3000:3000 &
kubectl port-forward -n cookbook svc/backend-lb 8014:8014 &
```

### Cleanup and Reset

**Reset the entire environment:**
```bash
# Delete namespace
kubectl delete namespace cookbook

# Restart minikube
minikube stop
minikube start
minikube addons enable ingress

# Rebuild images
eval $(minikube docker-env)
docker build -t r0nts/cookbook-backend:latest ./backend
docker build -t r0nts/cookbook-frontend:latest ./frontend

# Redeploy
cd deployment
./deploy.sh

# Configure to use local images
kubectl patch deployment backend -n cookbook -p '{"spec":{"template":{"spec":{"containers":[{"name":"backend","imagePullPolicy":"Never"}]}}}}'
kubectl patch deployment frontend -n cookbook -p '{"spec":{"template":{"spec":{"containers":[{"name":"frontend","imagePullPolicy":"Never"}]}}}}'
```

## Project Structure

```
cookbook/
├── backend/                    # Express.js backend
│   ├── server.ts               # Main server file
│   ├── dev.sh                  # Development script
│   ├── package.json             # Backend dependencies
│   ├── tsconfig.json           # TypeScript config
│   ├── Dockerfile              # Backend container config
│   └── dist/                   # Compiled JavaScript (generated)
├── frontend/                   # React frontend
│   ├── src/                    # Source files
│   ├── public/                 # Static assets
│   ├── dev.sh                  # Development script
│   ├── package.json            # Frontend dependencies
│   ├── vite.config.ts          # Vite configuration
│   ├── Dockerfile              # Frontend container config
│   └── dist/                   # Build output (generated)
├── deployment/                 # Kubernetes configurations
│   ├── k8s/                    # Kubernetes manifests
│   │   ├── namespace.yaml      # Namespace definition
│   │   ├── config-and-secrets.yaml  # ConfigMaps & Secrets
│   │   ├── mongo.yaml          # MongoDB deployment
│   │   ├── backend.yaml        # Backend deployment
│   │   ├── frontend.yaml       # Frontend deployment
│   │   └── ingress.yaml        # Ingress configuration
│   ├── deploy.sh               # Automated deployment script
│   ├── manage-access.sh        # Access management script
│   ├── README.md               # Deployment overview
│   ├── DEPLOYMENT.md           # Detailed deployment guide
│   └── ACCESS.md               # Access management guide
├── dev.sh                      # Combined development script
├── .env.example                # Environment variables template
└── README_DEV.md               # This file
```

## Contributing

1. Create a feature branch: `git checkout -b feature/your-feature`
2. Make your changes in the appropriate directory (`backend/` or `frontend/`)
3. Test locally:
   - Option 1: Use Kubernetes workflow (recommended for production-like testing)
   - Option 2: Use local development workflow for rapid iteration
4. Commit your changes: `git commit -m "Add your feature"`
5. Submit a pull request

### Development Best Practices

- **Code Changes**: Make changes in `backend/` or `frontend/` as needed
- **Testing**: Test with minikube to simulate production environment
- **Kubernetes**: Update deployment manifests if you change ports or configurations
- **Docker**: Images are automatically rebuilt on deployment

## Common Commands Reference

### Minikube Management
```bash
minikube start                    # Start cluster
minikube stop                     # Stop cluster
minikube status                    # Check status
minikube delete                    # Delete cluster
minikube ip                        # Get cluster IP
minikube tunnel                    # Start tunnel (for LoadBalancer access)
```

### Kubernetes Resources
```bash
kubectl get all -n cookbook       # View all resources
kubectl get pods -n cookbook      # View pods
kubectl logs -l app=backend -n cookbook  # View backend logs
kubectl describe pod <name> -n cookbook  # Pod details
kubectl exec -it <pod> -n cookbook -- /bin/sh  # Execute into pod
```

### Development Workflow
```bash
eval $(minikube docker-env)              # Set Docker daemon
docker build -t r0nts/cookbook-backend:latest ./backend  # Build backend
kubectl rollout restart deployment backend -n cookbook  # Restart pods
kubectl logs -f -l app=backend -n cookbook  # Follow logs
```

## Resources

- [Kubernetes Documentation](https://kubernetes.io/docs/home/)
- [Minikube Documentation](https://minikube.sigs.k8s.io/docs/)
- [Docker Documentation](https://docs.docker.com/)
- [kubectl Reference](https://kubernetes.io/docs/reference/kubectl/)
- [Express.js Documentation](https://expressjs.com/)
- [React Documentation](https://react.dev/)
- [Vite Documentation](https://vitejs.dev/)
- [TypeScript Documentation](https://www.typescriptlang.org/)

## Support

For issues or questions:
- **Kubernetes/Deployment**: See [deployment/README.md](./deployment/README.md) and [deployment/DEPLOYMENT.md](./deployment/DEPLOYMENT.md)
- **Access Issues**: See [deployment/ACCESS.md](./deployment/ACCESS.md)
- **Backend**: See [backend/README.md](./backend/README.md)
- **Frontend**: See [frontend/README.md](./frontend/README.md)