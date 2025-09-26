#!/bin/bash

echo "🔄 Restarting Polar production environment..."
echo ""

# Stop everything
echo "🛑 Stopping services..."
./stop-prod.sh

echo ""
echo "⏳ Waiting 3 seconds for cleanup..."
sleep 3

# Start everything fresh
echo ""
echo "🚀 Starting services..."
./start-prod.sh

echo ""
echo "🔄 Restart complete!"