#!/bin/bash

cd ~/traefik-setup

echo "🔄 Updating Traefik..."

# Pull latest image
docker-compose pull

# Restart with new image
docker-compose up -d

echo "✅ Traefik updated!"
docker-compose ps
