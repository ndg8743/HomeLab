# Traefik Infrastructure - Terraform Configuration

This directory contains Terraform configurations for managing the Traefik reverse proxy infrastructure using Infrastructure as Code (IaC).

## Overview

This Terraform configuration manages:
- Docker network for Traefik
- Traefik reverse proxy container with automatic SSL/TLS
- TinyAuth authentication service with Google OAuth
- Portainer container management UI
- PersonalSite application
- Prometheus metrics collection and monitoring
- Grafana dashboards and visualization
- Unified services dashboard
- All associated configurations and security settings

## Prerequisites

### 1. Install Terraform

**Ubuntu/Debian:**
```bash
wget -O- https://apt.releases.hashicorp.com/gpg | sudo gpg --dearmor -o /usr/share/keyrings/hashicorp-archive-keyring.gpg
echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/hashicorp.list
sudo apt update && sudo apt install terraform
```

**macOS (Homebrew):**
```bash
brew tap hashicorp/tap
brew install hashicorp/tap/terraform
```

**Verify Installation:**
```bash
terraform --version
```

### 2. Docker Requirements

- Docker Engine installed and running
- Docker socket accessible at `/var/run/docker.sock`
- Sufficient permissions to manage Docker resources

### 3. Existing Directory Structure

Ensure these directories exist before running Terraform:
```bash
mkdir -p /root/traefik-setup/traefik/config
mkdir -p /root/traefik-setup/traefik/acme
mkdir -p /root/traefik-setup/traefik/logs
mkdir -p /root/traefik-setup/traefik/portainer-data
```

Set proper permissions for ACME storage:
```bash
chmod 600 /root/traefik-setup/traefik/acme/acme.json 2>/dev/null || touch /root/traefik-setup/traefik/acme/acme.json && chmod 600 /root/traefik-setup/traefik/acme/acme.json
```

## File Structure

```
terraform/
├── provider.tf          # Docker provider configuration
├── variables.tf         # Input variables and defaults
├── network.tf          # Docker network definition
├── traefik.tf          # Traefik reverse proxy configuration
├── tinyauth.tf         # TinyAuth authentication service
├── portainer.tf        # Portainer container management
├── monitoring.tf       # Prometheus and Grafana monitoring
├── dashboard.tf        # Unified services dashboard
├── personal-site.tf    # PersonalSite container configuration
├── outputs.tf          # Output values
├── .gitignore          # Git ignore rules
├── terraform.tfvars.example  # Example variable values
└── README.md           # This file
```

## Usage Instructions

### 1. Initialize Terraform

Initialize the Terraform working directory and download required providers:

```bash
cd /root/traefik-setup/terraform
terraform init
```

### 2. Review the Plan

Preview what Terraform will create/modify:

```bash
terraform plan
```

For detailed output:
```bash
terraform plan -out=tfplan
```

### 3. Apply Configuration

Deploy the infrastructure:

```bash
terraform apply
```

Review the planned changes and type `yes` to confirm.

**Auto-approve (use with caution):**
```bash
terraform apply -auto-approve
```

### 4. View Outputs

After successful deployment, view the outputs:

```bash
terraform output
```

View specific output:
```bash
terraform output traefik_dashboard_url
terraform output infrastructure_summary
```

View outputs in JSON format:
```bash
terraform output -json
```

## Customization

### Override Default Variables

Create a `terraform.tfvars` file (gitignored by default):

```hcl
domain                  = "yourdomain.com"
email                   = "your-email@example.com"
traefik_image          = "traefik:v3.0"
environment            = "production"
traefik_log_level      = "INFO"
traefik_memory_limit   = 512
portainer_memory_limit = 256
```

### Use Command-line Variables

```bash
terraform apply -var="domain=example.com" -var="email=admin@example.com"
```

### Variable Files for Different Environments

**production.tfvars:**
```hcl
environment          = "production"
traefik_log_level   = "WARN"
traefik_memory_limit = 1024
```

**staging.tfvars:**
```hcl
environment          = "staging"
traefik_log_level   = "DEBUG"
traefik_memory_limit = 512
```

Apply with specific variable file:
```bash
terraform apply -var-file="production.tfvars"
```

## Adding New Projects

To add a new project/service to the infrastructure:

### Option 1: Create a New Terraform File

Create a new file (e.g., `my-app.tf`):

```hcl
resource "docker_image" "myapp" {
  name         = "myapp:latest"
  keep_locally = true
}

resource "docker_container" "myapp" {
  name  = "myapp"
  image = docker_image.myapp.image_id

  restart = "unless-stopped"

  networks_advanced {
    name = docker_network.traefik_public.name
  }

  security_opts = [
    "no-new-privileges:true"
  ]

  labels {
    label = "traefik.enable"
    value = "true"
  }

  labels {
    label = "traefik.http.routers.myapp.rule"
    value = "Host(`myapp.${var.domain}`)"
  }

  labels {
    label = "traefik.http.routers.myapp.entrypoints"
    value = "websecure"
  }

  labels {
    label = "traefik.http.routers.myapp.tls.certresolver"
    value = "letsencrypt"
  }

  labels {
    label = "traefik.http.services.myapp.loadbalancer.server.port"
    value = "8080"
  }

  depends_on = [
    docker_network.traefik_public,
    docker_container.traefik
  ]
}
```

### Option 2: Use Terraform Modules

Create a reusable module in `modules/web-app/`:

```hcl
# modules/web-app/main.tf
variable "name" {}
variable "image" {}
variable "domain" {}
variable "port" {}
variable "network_name" {}

resource "docker_image" "app" {
  name = var.image
  keep_locally = true
}

resource "docker_container" "app" {
  name  = var.name
  image = docker_image.app.image_id
  # ... rest of configuration
}
```

Use the module:
```hcl
module "blog" {
  source       = "./modules/web-app"
  name         = "blog"
  image        = "ghost:latest"
  domain       = "blog.${var.domain}"
  port         = "2368"
  network_name = docker_network.traefik_public.name
}
```

After adding new resources:
```bash
terraform plan
terraform apply
```

## Managing Infrastructure

### View Current State

```bash
# List all resources
terraform state list

# Show specific resource
terraform state show docker_container.traefik

# Show all state
terraform show
```

### Update Specific Resource

```bash
# Target specific resource for update
terraform apply -target=docker_container.traefik
```

### Refresh State

```bash
terraform refresh
```

### Format Configuration Files

```bash
terraform fmt
```

### Validate Configuration

```bash
terraform validate
```

## Destroying Infrastructure

### Destroy All Resources

**WARNING:** This will destroy all managed infrastructure!

```bash
terraform destroy
```

Review the destruction plan and type `yes` to confirm.

### Destroy Specific Resources

```bash
# Destroy only PersonalSite
terraform destroy -target=docker_container.personalsite

# Destroy multiple specific resources
terraform destroy -target=docker_container.personalsite -target=docker_container.portainer
```

### Prevent Accidental Destruction

Add lifecycle rules to critical resources:

```hcl
resource "docker_container" "traefik" {
  # ... other configuration ...

  lifecycle {
    prevent_destroy = true
  }
}
```

## Troubleshooting

### Common Issues

**1. Docker socket permission denied:**
```bash
sudo chmod 666 /var/run/docker.sock
# Or add user to docker group:
sudo usermod -aG docker $USER
```

**2. Container already exists:**
```bash
# Import existing container
terraform import docker_container.traefik traefik
```

**3. State lock issues:**
```bash
# Force unlock (use with caution)
terraform force-unlock LOCK_ID
```

**4. Provider initialization fails:**
```bash
# Clean and reinitialize
rm -rf .terraform .terraform.lock.hcl
terraform init
```

### Debugging

Enable detailed logging:
```bash
export TF_LOG=DEBUG
export TF_LOG_PATH=./terraform.log
terraform apply
```

## Best Practices

1. **Always run `terraform plan` before `apply`**
   - Review changes carefully before applying

2. **Use version control**
   - Commit `.tf` files to Git
   - Never commit `.tfstate` files or `.tfvars` with secrets

3. **Use remote state for teams**
   - Configure S3, Terraform Cloud, or other remote backends
   - Enable state locking

4. **Use workspaces for environments**
   ```bash
   terraform workspace new production
   terraform workspace new staging
   terraform workspace select production
   ```

5. **Tag resources appropriately**
   - Use labels for organization and cost tracking

6. **Keep provider versions locked**
   - Use version constraints in `required_providers`

7. **Use variables for everything configurable**
   - Never hardcode values that might change

8. **Document your code**
   - Add descriptions to all variables and outputs
   - Comment complex logic

## Security Considerations

1. **Sensitive Variables**
   - Use environment variables: `TF_VAR_secret_name`
   - Use Terraform Cloud for secret management
   - Never commit `.tfvars` files with secrets

2. **State File Security**
   - State files contain sensitive data
   - Use encrypted remote state storage
   - Restrict access to state files

3. **Docker Socket Access**
   - Be cautious with docker.sock volume mounts
   - Consider using Docker contexts for remote management

## Backup and Recovery

### Backup State

```bash
# Backup current state
cp terraform.tfstate terraform.tfstate.backup-$(date +%Y%m%d-%H%M%S)
```

### Export State

```bash
terraform show -json > state-backup.json
```

### Restore from Backup

```bash
cp terraform.tfstate.backup terraform.tfstate
```

## CI/CD Integration

### Example GitHub Actions Workflow

```yaml
name: Terraform

on:
  push:
    branches: [ main ]
  pull_request:

jobs:
  terraform:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3

      - name: Setup Terraform
        uses: hashicorp/setup-terraform@v2

      - name: Terraform Init
        run: terraform init

      - name: Terraform Validate
        run: terraform validate

      - name: Terraform Plan
        run: terraform plan

      - name: Terraform Apply
        if: github.ref == 'refs/heads/main'
        run: terraform apply -auto-approve
```

## Additional Resources

- [Terraform Documentation](https://www.terraform.io/docs)
- [Docker Provider Documentation](https://registry.terraform.io/providers/kreuzwerker/docker/latest/docs)
- [Traefik Documentation](https://doc.traefik.io/traefik/)
- [Best Practices](https://www.terraform.io/docs/cloud/guides/recommended-practices/index.html)

## Support

For issues or questions:
1. Check the Terraform documentation
2. Review the provider documentation
3. Check container logs: `docker logs <container-name>`
4. Review Traefik logs: `/root/traefik-setup/traefik/logs/`

## License

This configuration is provided as-is for infrastructure management purposes.
