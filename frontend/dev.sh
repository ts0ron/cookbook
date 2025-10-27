#!/bin/bash

# Development script for frontend
# Sets environment variables and starts the dev server

export FRONTEND_PORT=${FRONTEND_PORT:-3000}
export BACKEND_PORT=${BACKEND_PORT:-8014}
export VITE_API_BASE_URL=${VITE_API_BASE_URL:-http://localhost:$BACKEND_PORT}

echo "🚀 Starting frontend development server..."
echo "📍 Frontend URL: http://localhost:$FRONTEND_PORT"
echo "🔗 API URL: $VITE_API_BASE_URL"
echo ""

# Start Vite dev server
exec npx vite --port $FRONTEND_PORT
