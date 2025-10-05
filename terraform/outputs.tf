output "network_name" {
  description = "Name of the Traefik public network"
  value       = docker_network.traefik_public.name
}

output "network_id" {
  description = "ID of the Traefik public network"
  value       = docker_network.traefik_public.id
}

output "network_subnet" {
  description = "Subnet of the Traefik public network"
  value       = docker_network.traefik_public.ipam_config[0].subnet
}

output "traefik_container_id" {
  description = "ID of the Traefik container"
  value       = docker_container.traefik.id
}

output "traefik_container_name" {
  description = "Name of the Traefik container"
  value       = docker_container.traefik.name
}

output "traefik_image" {
  description = "Traefik Docker image used"
  value       = docker_image.traefik.name
}

output "portainer_container_id" {
  description = "ID of the Portainer container"
  value       = docker_container.portainer.id
}

output "portainer_container_name" {
  description = "Name of the Portainer container"
  value       = docker_container.portainer.name
}

output "personalsite_container_id" {
  description = "ID of the PersonalSite container"
  value       = docker_container.personalsite.id
}

output "personalsite_container_name" {
  description = "Name of the PersonalSite container"
  value       = docker_container.personalsite.name
}

output "traefik_dashboard_url" {
  description = "URL to access Traefik dashboard"
  value       = "https://traefik.${var.domain}"
}

output "portainer_url" {
  description = "URL to access Portainer"
  value       = "https://portainer.${var.domain}"
}

output "personalsite_url" {
  description = "URL to access PersonalSite"
  value       = "https://${var.domain}"
}

output "letsencrypt_email" {
  description = "Email used for Let's Encrypt certificates"
  value       = var.email
}

output "environment" {
  description = "Current environment"
  value       = var.environment
}

output "tinyauth_container_id" {
  description = "ID of the TinyAuth container"
  value       = docker_container.tinyauth.id
}

output "tinyauth_url" {
  description = "URL to access TinyAuth"
  value       = "https://auth.${var.domain}"
}

output "prometheus_container_id" {
  description = "ID of the Prometheus container"
  value       = docker_container.prometheus.id
}

output "prometheus_url" {
  description = "URL to access Prometheus"
  value       = "https://prometheus.${var.domain}"
}

output "grafana_container_id" {
  description = "ID of the Grafana container"
  value       = docker_container.grafana.id
}

output "grafana_url" {
  description = "URL to access Grafana"
  value       = "https://grafana.${var.domain}"
}

output "dashboard_container_id" {
  description = "ID of the Dashboard container"
  value       = docker_container.dashboard.id
}

output "dashboard_url" {
  description = "URL to access Dashboard"
  value       = "https://${var.domain}/dashboard"
}

output "infrastructure_summary" {
  description = "Summary of deployed infrastructure"
  value = {
    network = {
      name   = docker_network.traefik_public.name
      subnet = docker_network.traefik_public.ipam_config[0].subnet
    }
    containers = {
      traefik = {
        name   = docker_container.traefik.name
        url    = "https://traefik.${var.domain}"
        status = "running"
      }
      tinyauth = {
        name   = docker_container.tinyauth.name
        url    = "https://auth.${var.domain}"
        status = "running"
      }
      portainer = {
        name   = docker_container.portainer.name
        url    = "https://portainer.${var.domain}"
        status = "running"
      }
      prometheus = {
        name   = docker_container.prometheus.name
        url    = "https://prometheus.${var.domain}"
        status = "running"
      }
      grafana = {
        name   = docker_container.grafana.name
        url    = "https://grafana.${var.domain}"
        status = "running"
      }
      dashboard = {
        name   = docker_container.dashboard.name
        url    = "https://${var.domain}/dashboard"
        status = "running"
      }
      personalsite = {
        name   = docker_container.personalsite.name
        url    = "https://${var.domain}"
        status = "running"
      }
    }
    domain = var.domain
    email  = var.email
  }
}
