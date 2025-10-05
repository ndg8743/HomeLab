#!/bin/bash

echo "🔍 Weekly Security Check - $(date)"

echo ""
echo "1. Checking for Docker updates..."
docker images --format "{{.Repository}}:{{.Tag}}" | xargs -L1 docker pull

echo ""
echo "2. Checking banned IPs..."
sudo fail2ban-client status traefik-auth

echo ""
echo "3. Checking SSL certificate expiry..."
echo | openssl s_client -servername gopee.dev -connect gopee.dev:443 2>/dev/null | openssl x509 -noout -enddate

echo ""
echo "4. Checking disk space..."
df -h

echo ""
echo "5. Checking firewall status..."
sudo ufw status

echo ""
echo "6. Recent high-error access patterns..."
docker exec traefik tail -1000 /var/log/traefik/access.log | grep -c "error"

echo ""
echo "✅ Security check complete"
