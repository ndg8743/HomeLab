#!/bin/bash

# Project Deployment Script
# Usage: ./deploy.sh

set -e

PROJECT_NAME="myapp"
DOMAIN="myapp.gopee.dev"

echo "🚀 Deploying $PROJECT_NAME..."

# Pull latest code (if using git)
if [ -d ".git" ]; then
    echo "📦 Pulling latest code..."
    git pull
fi

# Build and deploy
echo "🏗️  Building and starting containers..."
docker-compose up -d --build

# Show status
echo "✅ Deployment complete!"
echo "🌐 Your app should be available at: https://$DOMAIN"
echo ""
echo "📊 Container status:"
docker-compose ps

echo ""
echo "📋 To view logs, run: docker-compose logs -f"
