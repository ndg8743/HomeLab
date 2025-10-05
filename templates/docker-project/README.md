# Docker Project Deployment with Traefik

## Quick Start

1. **Copy this template** to your project directory:
   ```bash
   cp -r ~/traefik-setup/templates/docker-project ~/traefik-setup/projects/your-project-name
   cd ~/traefik-setup/projects/your-project-name
   ```

2. **Customize docker-compose.yml**:
   - Replace `myapp` with your application name
   - Update the domain: `Host(\`myapp.gopee.dev\`)`
   - Set the correct internal port your app uses
   - Add environment variables, volumes, etc.

3. **Customize deploy.sh**:
   - Update PROJECT_NAME
   - Update DOMAIN

4. **Make deploy script executable**:
   ```bash
   chmod +x deploy.sh
   ```

5. **Deploy**:
   ```bash
   ./deploy.sh
   ```

## Common Configurations

### Database + App Example

```yaml
services:
  app:
    # ... app configuration with Traefik labels

  postgres:
    image: postgres:15
    environment:
      POSTGRES_PASSWORD: ${DB_PASSWORD}
    volumes:
      - postgres-data:/var/lib/postgresql/data
    networks:
      - internal

networks:
  traefik-public:
    external: true
  internal:
    internal: true

volumes:
  postgres-data:
```

### Multiple Domains

```yaml
labels:
  - "traefik.http.routers.myapp.rule=Host(`app.com`) || Host(`www.app.com`) || Host(`alt.app.com`)"
```

### Path-based Routing

```yaml
labels:
  - "traefik.http.routers.api.rule=Host(`gopee.dev`) && PathPrefix(`/api`)"
```

## Troubleshooting

**Check Traefik logs:**
```bash
docker logs traefik
```

**Check app logs:**
```bash
cd ~/traefik-setup/projects/your-project
docker-compose logs -f
```

**Verify DNS:**
```bash
dig gopee.dev
```

**Test SSL:**
```bash
curl -I https://gopee.dev
```
