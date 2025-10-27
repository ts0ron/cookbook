#!/bin/bash

# Development script for backend
# Sets environment variables and starts the dev server

export BACKEND_PORT=${BACKEND_PORT:-8014}
export NODE_ENV=${NODE_ENV:-development}

echo "🚀 Starting backend development server..."
echo "📍 Backend URL: http://localhost:$BACKEND_PORT"
echo "🌍 Environment: $NODE_ENV"
echo ""

# Start ts-node-dev
exec npx ts-node-dev --respawn --transpile-only server.ts
