# Terraform Quick Start Guide

## 5-Minute Setup

### Step 1: Install Terraform (if not installed)

```bash
# Ubuntu/Debian
wget -O- https://apt.releases.hashicorp.com/gpg | sudo gpg --dearmor -o /usr/share/keyrings/hashicorp-archive-keyring.gpg
echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/hashicorp.list
sudo apt update && sudo apt install terraform -y
```

### Step 2: Prepare Environment

```bash
# Ensure required directories exist
mkdir -p /root/traefik-setup/traefik/{config,acme,logs,portainer-data}

# Set correct permissions for ACME
touch /root/traefik-setup/traefik/acme/acme.json
chmod 600 /root/traefik-setup/traefik/acme/acme.json

# Navigate to terraform directory
cd /root/traefik-setup/terraform
```

### Step 3: Initialize Terraform

```bash
terraform init
```

### Step 4: Review Plan

```bash
terraform plan
```

### Step 5: Deploy Infrastructure

```bash
terraform apply
```

Type `yes` when prompted.

### Step 6: View Results

```bash
terraform output infrastructure_summary
```

## Access Your Services

After deployment, access your services at:

- **PersonalSite**: https://gopee.dev
- **Traefik Dashboard**: https://traefik.gopee.dev
- **Portainer**: https://portainer.gopee.dev

## Common Commands

```bash
# View all outputs
terraform output

# View specific output
terraform output traefik_dashboard_url

# View current state
terraform show

# Update infrastructure
terraform apply

# Destroy everything (CAREFUL!)
terraform destroy
```

## Customization

To customize settings, create a `terraform.tfvars` file:

```bash
cp terraform.tfvars.example terraform.tfvars
nano terraform.tfvars
```

Edit the values and run `terraform apply` again.

## Troubleshooting

**Permission Error:**
```bash
sudo chmod 666 /var/run/docker.sock
```

**Container Already Exists:**
```bash
terraform import docker_container.traefik traefik
```

**Need Help:**
```bash
terraform --help
terraform plan --help
```

For more details, see [README.md](README.md)
