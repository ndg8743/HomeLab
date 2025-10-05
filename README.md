# HomeLab Infrastructure

Self-hosted infrastructure for gopee.dev using Traefik reverse proxy, Docker containers, and comprehensive security hardening.

## Architecture

- **Reverse Proxy**: Traefik v3.0 with automatic SSL/TLS via Let's Encrypt
- **Authentication**: TinyAuth with Google OAuth
- **Monitoring**: Prometheus + Grafana
- **Container Management**: Portainer
- **Services Dashboard**: Unified dashboard at gopee.dev/dashboard
- **Security**: Fail2Ban, UFW firewall, rate limiting, DDoS protection

## Services

| Service | URL | Description |
|---------|-----|-------------|
| PersonalSite | https://gopee.dev | Main website |
| Auth | https://auth.gopee.dev | TinyAuth authentication portal |
| Dashboard | https://gopee.dev/dashboard | Unified services dashboard |
| Portainer | https://portainer.gopee.dev | Docker container management |
| Grafana | https://grafana.gopee.dev | Monitoring dashboards |
| Prometheus | https://prometheus.gopee.dev | Metrics collection |

## Directory Structure

```
HomeLab/
├── traefik/                 # Traefik reverse proxy configuration
│   ├── config/             # Static and dynamic configuration
│   ├── acme/              # Let's Encrypt certificates
│   └── logs/              # Access and error logs
├── projects/               # Docker compose projects
│   ├── tinyauth/          # Google OAuth authentication
│   ├── monitoring/        # Prometheus + Grafana
│   ├── portainer/         # Container management
│   └── dashboard/         # Services dashboard
├── terraform/              # Infrastructure as Code
└── docker-compose.yml      # Main Traefik service
```

## Quick Start

### Prerequisites

- Docker and Docker Compose
- Domain with DNS pointing to your server
- Ports 80 and 443 open

### Deploy Infrastructure

```bash
# Create Docker network
docker network create traefik-public

# Start Traefik
docker compose up -d

# Deploy services
cd projects/tinyauth && docker compose up -d
cd ../monitoring && docker compose up -d
cd ../portainer && docker compose up -d
cd ../dashboard && docker compose up -d
```

### Using Terraform

```bash
cd terraform
terraform init
terraform plan
terraform apply
```

## Security Features

### Network Security
- **UFW Firewall**: Only ports 22, 80, 443 exposed
- **Fail2Ban**: Automatic IP banning for suspicious activity
- **Rate Limiting**: DDoS protection at Traefik level
- **SSL/TLS**: Automatic HTTPS with strong cipher suites

### Container Security
- Read-only filesystems with tmpfs mounts
- No new privileges security option
- Resource limits (CPU and memory)
- Security headers (HSTS, CSP, XSS protection)

### Authentication
- TinyAuth ForwardAuth middleware
- Google OAuth for all admin interfaces
- Session management with secure cookies

## Configuration

### DNS Records

Required A records pointing to your server IP:

```
@              -> YOUR_SERVER_IP
www            -> YOUR_SERVER_IP
auth           -> YOUR_SERVER_IP
portainer      -> YOUR_SERVER_IP
grafana        -> YOUR_SERVER_IP
prometheus     -> YOUR_SERVER_IP
```

### Environment Variables

See individual service directories for required environment variables.

## Monitoring

Access Grafana at https://grafana.gopee.dev

Pre-configured dashboards:
- Traefik metrics
- Container resource usage
- System health

## Backup

```bash
# Backup Traefik certificates
cp -r traefik/acme ~/backups/

# Backup service data
docker run --rm -v prometheus-data:/data -v ~/backups:/backup alpine tar czf /backup/prometheus-data.tar.gz /data
```

## Maintenance

### Update Services

```bash
# Update Traefik
docker compose pull
docker compose up -d

# Update individual service
cd projects/portainer
docker compose pull
docker compose up -d
```

### View Logs

```bash
# Traefik logs
docker logs traefik -f

# Service logs
docker logs tinyauth -f
```

### Restart Services

```bash
# Restart all
docker compose restart

# Restart specific service
docker restart traefik
```

## Troubleshooting

### SSL Certificate Issues

```bash
# Check certificates
cat traefik/acme/acme.json | jq

# Verify DNS
dig gopee.dev
```

### Service Not Accessible

```bash
# Check container status
docker ps

# Check Traefik routes
docker logs traefik | grep -i error

# Test connectivity
curl -I https://gopee.dev
```

### Authentication Not Working

```bash
# Check TinyAuth
docker logs tinyauth

# Verify OAuth credentials
docker inspect tinyauth | grep -i google
```

## License

Personal infrastructure configuration.
