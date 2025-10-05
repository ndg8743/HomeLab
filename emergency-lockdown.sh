#!/bin/bash

# Emergency lockdown script
# Use only when under severe attack

echo "🚨 EMERGENCY LOCKDOWN ACTIVATED"

# Enable strict rate limiting
cat > ~/traefik-setup/traefik/config/emergency.yml << EOF
http:
  middlewares:
    emergency-rate-limit:
      rateLimit:
        average: 5
        period: 1s
        burst: 2
EOF

# Restart Traefik
cd ~/traefik-setup
docker-compose restart

# Enable Cloudflare "I'm Under Attack" mode (requires API)
# curl -X PATCH "https://api.cloudflare.com/client/v4/zones/ZONE_ID/settings/security_level" \
#   -H "X-Auth-Email: email@example.com" \
#   -H "X-Auth-Key: API_KEY" \
#   -H "Content-Type: application/json" \
#   --data '{"value":"under_attack"}'

echo "✅ Emergency measures activated"
echo "Remember to revert changes after attack subsides"
