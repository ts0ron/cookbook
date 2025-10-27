#!/bin/bash

# Script to manage access to the Cookbook services

ACTION=${1:-start}

case "$ACTION" in
    start)
        echo "🔧 Setting up access to Cookbook services..."
        
        # Check if kubectl is available
        if ! command -v kubectl &> /dev/null; then
            echo "❌ kubectl is not installed."
            exit 1
        fi
        
        # Check if we're on minikube
        if kubectl config current-context | grep -q "minikube"; then
            echo "Using minikube tunnel..."
            
            # Kill any existing tunnels
            sudo pkill -f "minikube tunnel" || true
            sleep 1
            
            # Check if tunnel is still running
            if pgrep -f "minikube tunnel" > /dev/null; then
                echo "⚠️  Could not stop existing tunnel. Please run: sudo pkill -f 'minikube tunnel'"
                exit 1
            fi
            
            # Start minikube tunnel in background
            echo "Starting minikube tunnel..."
            nohup minikube tunnel > /tmp/minikube-tunnel.log 2>&1 &
            sleep 3
            
            if pgrep -f "minikube tunnel" > /dev/null; then
                echo "✅ minikube tunnel started"
                echo "📝 View logs: tail -f /tmp/minikube-tunnel.log"
                echo ""
                echo "🌐 Access your services:"
                echo "- Frontend: http://localhost:3000"
                echo "- Backend: http://localhost:8014/hello/world"
            else
                echo "❌ Failed to start minikube tunnel"
                echo "Check logs: cat /tmp/minikube-tunnel.log"
                exit 1
            fi
        else
            echo "Using port-forwarding..."
            
            # Stop any existing port-forwards
            pkill -f "kubectl port-forward.*frontend-lb" || true
            pkill -f "kubectl port-forward.*backend-lb" || true
            sleep 1
            
            # Start port-forwarding
            echo "Forwarding frontend to localhost:3000..."
            kubectl port-forward -n cookbook svc/frontend-lb 3000:3000 > /tmp/frontend-portforward.log 2>&1 &
            
            sleep 1
            echo "Forwarding backend to localhost:8014..."
            kubectl port-forward -n cookbook svc/backend-lb 8014:8014 > /tmp/backend-portforward.log 2>&1 &
            
            sleep 2
            
            # Check if port-forwards are running
            if pgrep -f "kubectl port-forward.*frontend-lb" > /dev/null && \
               pgrep -f "kubectl port-forward.*backend-lb" > /dev/null; then
                echo "✅ Port-forwarding started"
                echo ""
                echo "🌐 Access your services:"
                echo "- Frontend: http://localhost:3000"
                echo "- Backend: http://localhost:8014/hello/world"
            else
                echo "❌ Failed to start port-forwarding"
                echo "Check logs: cat /tmp/frontend-portforward.log"
                exit 1
            fi
        fi
        ;;
    
    stop)
        echo "🛑 Stopping access..."
        
        # Stop minikube tunnel
        if pgrep -f "minikube tunnel" > /dev/null; then
            echo "Stopping minikube tunnel..."
            sudo pkill -f "minikube tunnel"
            sleep 1
            echo "✅ minikube tunnel stopped"
        fi
        
        # Stop port-forwards
        if pgrep -f "kubectl port-forward" > /dev/null; then
            echo "Stopping port-forwards..."
            pkill -f "kubectl port-forward.*frontend-lb"
            pkill -f "kubectl port-forward.*backend-lb"
            sleep 1
            echo "✅ Port-forwards stopped"
        fi
        
        echo "✅ Access stopped"
        ;;
    
    status)
        echo "📊 Access Status:"
        echo ""
        
        # Check minikube tunnel
        if pgrep -f "minikube tunnel" > /dev/null; then
            echo "✅ minikube tunnel: Running"
        else
            echo "❌ minikube tunnel: Not running"
        fi
        
        # Check port-forwards
        if pgrep -f "kubectl port-forward.*frontend-lb" > /dev/null; then
            echo "✅ Frontend port-forward: Running (localhost:3000)"
        else
            echo "❌ Frontend port-forward: Not running"
        fi
        
        if pgrep -f "kubectl port-forward.*backend-lb" > /dev/null; then
            echo "✅ Backend port-forward: Running (localhost:8014)"
        else
            echo "❌ Backend port-forward: Not running"
        fi
        ;;
    
    *)
        echo "Usage: $0 {start|stop|status}"
        echo ""
        echo "Commands:"
        echo "  start   - Setup access to services"
        echo "  stop    - Stop access to services"
        echo "  status  - Check status of access methods"
        exit 1
        ;;
esac

