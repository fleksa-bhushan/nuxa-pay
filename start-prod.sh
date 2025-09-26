#!/bin/bash

# First ensure everything is stopped
echo "🧹 Ensuring clean state..."
./stop-prod.sh

echo "🚀 Starting Polar in PRODUCTION mode..."

# Start Docker services
echo "📦 Starting Docker services..."
cd /home/ubuntu/polar/server
docker-compose up -d

# Wait for services to be ready
echo "⏳ Waiting for services..."
sleep 10

# Build frontend for production
echo "🔨 Building frontend for production (this takes a few minutes)..."
cd /home/ubuntu/polar/clients
~/.local/bin/pnpm build

# Build backoffice static files
echo "🎨 Building backoffice static files..."
cd /home/ubuntu/polar/server/polar/web_backoffice
pnpm run build:css
pnpm run build:js

# Start backend with proper process management
echo "🔧 Starting backend API (production mode)..."
cd /home/ubuntu/polar/server
nohup uv run uvicorn polar.app:app --host 0.0.0.0 --port 8000 > /tmp/polar-api.log 2>&1 &
echo $! > /tmp/polar-api.pid
echo "API started with PID $(cat /tmp/polar-api.pid)"

# Start SINGLE worker instance with proper logging
echo "⚙️ Starting background worker..."
nohup uv run task worker > /tmp/polar-worker.log 2>&1 &
echo $! > /tmp/polar-worker.pid
echo "Worker started with PID $(cat /tmp/polar-worker.pid)"

# Start frontend in PRODUCTION mode
echo "🎨 Starting frontend (production mode)..."
cd /home/ubuntu/polar/clients/apps/web
nohup ~/.local/bin/pnpm start > /tmp/polar-frontend.log 2>&1 &
echo $! > /tmp/polar-frontend.pid
echo "Frontend started with PID $(cat /tmp/polar-frontend.pid)"

echo ""
echo "✅ All services started in PRODUCTION mode!"
echo ""
echo "🌐 Access: https://pay.nuxa.ai"
echo "📋 Logs: tail -f /tmp/polar-*.log"
echo "📊 Status: ps aux | grep -E 'uvicorn|dramatiq|next'"
echo ""
echo "🛑 To stop: ./stop-prod.sh"