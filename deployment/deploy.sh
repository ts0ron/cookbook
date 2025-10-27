#!/bin/bash

set -e

echo "🚀 Deploying Cookbook to Kubernetes..."

# Check if kubectl is available
if ! command -v kubectl &> /dev/null; then
    echo "❌ kubectl is not installed. Please install kubectl first."
    exit 1
fi

# Function to stop existing port-forwards
cleanup_port_forward() {
    echo ""
    echo "🧹 Cleaning up existing port-forwards..."
    pkill -f "kubectl port-forward.*frontend-lb" || true
    pkill -f "kubectl port-forward.*backend-lb" || true
    sleep 1
}

# Function to setup access
setup_access() {
    # Check if we're on minikube
    if kubectl config current-context | grep -q "minikube"; then
        echo ""
        echo "🔧 Setting up minikube tunnel for automatic access..."
        # Kill any existing minikube tunnels
        sudo pkill -f "minikube tunnel" || true
        sleep 1
        
        # Start minikube tunnel in background
        echo "Starting minikube tunnel..."
        nohup minikube tunnel > /tmp/minikube-tunnel.log 2>&1 &
        sleep 3
        
        echo "✅ minikube tunnel started"
        echo "📝 Access logs with: tail -f /tmp/minikube-tunnel.log"
        echo ""
        echo "🌐 Your services are now accessible on:"
        echo "- Frontend: http://localhost:3000"
        echo "- Backend: http://localhost:8014/hello/world"
    else
        # Setup port-forwarding for non-minikube environments
        echo ""
        echo "🔧 Setting up port-forwarding for access..."
        cleanup_port_forward
        
        echo "Forwarding frontend to localhost:3000..."
        kubectl port-forward -n cookbook svc/frontend-lb 3000:3000 > /tmp/frontend-portforward.log 2>&1 &
        
        echo "Forwarding backend to localhost:8014..."
        kubectl port-forward -n cookbook svc/backend-lb 8014:8014 > /tmp/backend-portforward.log 2>&1 &
        
        sleep 2
        echo ""
        echo "✅ Port-forwarding started"
        echo "🌐 Your services are now accessible on:"
        echo "- Frontend: http://localhost:3000"
        echo "- Backend: http://localhost:8014/hello/world"
        echo ""
        echo "💡 Note: Port-forwarding will stop when you close this session."
        echo "💡 To stop: pkill -f 'kubectl port-forward'"
    fi
}

echo ""
echo "Step 1: Applying namespace..."
kubectl apply -f k8s/namespace.yaml

echo ""
echo "Step 2: Applying config and secrets..."
kubectl apply -f k8s/config-and-secrets.yaml

echo ""
echo "Step 3: Deploying MongoDB..."
kubectl apply -f k8s/mongo.yaml

echo ""
echo "Step 4: Deploying backend..."
kubectl apply -f k8s/backend.yaml

echo ""
echo "Step 5: Deploying frontend..."
kubectl apply -f k8s/frontend.yaml

echo ""
echo "Step 6: Applying ingress..."
kubectl apply -f k8s/ingress.yaml

echo ""
echo "✅ Deployment complete!"
echo ""
echo "Waiting for pods to be ready..."
kubectl wait --for=condition=ready pod -l app=backend -n cookbook --timeout=120s
kubectl wait --for=condition=ready pod -l app=frontend -n cookbook --timeout=120s

echo ""
echo "📊 Current status:"
kubectl get all -n cookbook

# Automatically setup access
setup_access

echo ""
echo "═══════════════════════════════════════════════"
echo "🎉 Deployment and access setup complete!"
echo "═══════════════════════════════════════════════"
echo ""
echo "📝 Access Instructions:"
echo ""
echo "🌐 Direct Service Access:"
echo "- Frontend: http://localhost:3000"
echo "- Backend API: http://localhost:8014/hello/world"
echo ""
echo "🔧 Other Access Methods:"
echo "- Via Ingress: http://localhost/ (requires ingress setup)"
echo ""
echo "🛑 To stop access:"
if kubectl config current-context | grep -q "minikube"; then
    echo "  sudo pkill -f 'minikube tunnel'"
else
    echo "  pkill -f 'kubectl port-forward'"
fi
echo ""

