#!/bin/bash

BACKUP_DIR=~/backups/traefik-$(date +%Y%m%d_%H%M%S)
mkdir -p $BACKUP_DIR

# Backup Traefik configuration
cp -r ~/traefik-setup/traefik/config $BACKUP_DIR/
cp ~/traefik-setup/docker-compose.yml $BACKUP_DIR/
cp ~/traefik-setup/traefik/acme/acme.json $BACKUP_DIR/

# Backup all project configurations
cp -r ~/traefik-setup/projects $BACKUP_DIR/

echo "✅ Backup saved to: $BACKUP_DIR"
