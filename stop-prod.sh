#!/bin/bash

echo "🛑 Stopping Polar PRODUCTION environment..."

# Kill all worker and API processes more aggressively
echo "Stopping all application processes..."
pkill -9 -f "dramatiq"
pkill -9 -f "uv run task worker"
pkill -9 -f "uvicorn"
pkill -9 -f "pnpm start"
pkill -9 -f "next"

# Clean up zombie processes
echo "Cleaning up zombie processes..."
ps aux | grep defunct | awk '{print $2}' | xargs -r kill -9 2>/dev/null

# Force kill processes on ports using lsof (more reliable)
echo "Killing processes on ports 3000 and 8000..."
lsof -ti:3000 | xargs -r kill -9 2>/dev/null
lsof -ti:8000 | xargs -r kill -9 2>/dev/null

# Remove PID files if they exist
echo "Cleaning up PID files..."
rm -f /tmp/polar-*.pid 2>/dev/null

# Stop Docker services
echo "Stopping Docker services..."
cd /home/ubuntu/polar/server
docker-compose down

# Clear Redis queue (helps with stuck webhooks)
echo "Clearing Redis queues..."
docker-compose up -d redis
sleep 2
docker-compose exec -T redis redis-cli FLUSHDB || echo "Redis flush failed (may be down)"
docker-compose stop redis

echo "✅ All PRODUCTION services stopped and cleaned!"