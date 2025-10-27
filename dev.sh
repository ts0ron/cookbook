#!/bin/bash

# Combined development script to run both frontend and backend
# This script starts both services in the background

# Load environment variables from .env if it exists
if [ -f ".env" ]; then
    export $(grep -v '^#' .env | xargs)
fi

# Set defaults if not set
export FRONTEND_PORT=${FRONTEND_PORT:-3000}
export BACKEND_PORT=${BACKEND_PORT:-8014}
export VITE_API_BASE_URL=${VITE_API_BASE_URL:-http://localhost:$BACKEND_PORT}
export NODE_ENV=${NODE_ENV:-development}

echo "🚀 Starting Cookbook Development Environment..."
echo "📍 Frontend: http://localhost:$FRONTEND_PORT"
echo "📍 Backend: http://localhost:$BACKEND_PORT"
echo "🔗 API URL: $VITE_API_BASE_URL"
echo ""

# Function to cleanup background processes on exit
cleanup() {
    echo ""
    echo "🛑 Stopping development servers..."
    kill 0
}

trap cleanup EXIT

# Start backend in background
echo "Starting backend..."
cd backend && ./dev.sh &
BACKEND_PID=$!

# Wait a moment for backend to start
sleep 2

# Start frontend in background
echo "Starting frontend..."
cd frontend && ./dev.sh &
FRONTEND_PID=$!

echo ""
echo "✅ Both servers started!"
echo "📝 Press Ctrl+C to stop all servers"
echo ""

# Wait for both processes
wait
