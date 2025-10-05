variable "domain" {
  description = "Primary domain for the infrastructure"
  type        = string
  default     = "gopee.dev"
}

variable "email" {
  description = "Email address for Let's Encrypt certificates"
  type        = string
  default     = "ndg8743@gmail.com"
}

variable "traefik_image" {
  description = "Traefik Docker image version"
  type        = string
  default     = "traefik:v3.0"
}

variable "network_name" {
  description = "Docker network name for Traefik"
  type        = string
  default     = "traefik-public"
}

variable "traefik_dashboard_enabled" {
  description = "Enable Traefik dashboard"
  type        = bool
  default     = true
}

variable "traefik_log_level" {
  description = "Traefik log level (DEBUG, INFO, WARN, ERROR)"
  type        = string
  default     = "INFO"
}

variable "traefik_memory_limit" {
  description = "Memory limit for Traefik container"
  type        = number
  default     = 512
}

variable "portainer_image" {
  description = "Portainer Docker image version"
  type        = string
  default     = "portainer/portainer-ce:latest"
}

variable "portainer_memory_limit" {
  description = "Memory limit for Portainer container"
  type        = number
  default     = 256
}

variable "personalsite_image" {
  description = "PersonalSite Docker image"
  type        = string
  default     = "personalsite:latest"
}

variable "personalsite_memory_limit" {
  description = "Memory limit for PersonalSite container"
  type        = number
  default     = 256
}

variable "acme_storage_path" {
  description = "Path to store Let's Encrypt certificates"
  type        = string
  default     = "/root/traefik-setup/traefik/acme"
}

variable "traefik_config_path" {
  description = "Path to Traefik configuration files"
  type        = string
  default     = "/root/traefik-setup/traefik/config"
}

variable "traefik_logs_path" {
  description = "Path to Traefik log files"
  type        = string
  default     = "/root/traefik-setup/traefik/logs"
}

variable "portainer_data_path" {
  description = "Path to Portainer data directory"
  type        = string
  default     = "/root/traefik-setup/traefik/portainer-data"
}

variable "environment" {
  description = "Environment name (production, staging, development)"
  type        = string
  default     = "production"
}

# TinyAuth variables
variable "tinyauth_image" {
  description = "TinyAuth Docker image version"
  type        = string
  default     = "ghcr.io/steveiliop56/tinyauth:v3"
}

variable "tinyauth_memory_limit" {
  description = "Memory limit for TinyAuth container"
  type        = number
  default     = 256
}

variable "tinyauth_secret" {
  description = "TinyAuth secret for cookie encryption (32 characters)"
  type        = string
  sensitive   = true
  default     = "CHANGE_ME_TINYAUTH_SECRET"
}

variable "google_client_id" {
  description = "Google OAuth Client ID"
  type        = string
  sensitive   = true
  default     = "CHANGE_ME_GOOGLE_CLIENT_ID"
}

variable "google_client_secret" {
  description = "Google OAuth Client Secret"
  type        = string
  sensitive   = true
  default     = "CHANGE_ME_GOOGLE_CLIENT_SECRET"
}

# Monitoring variables
variable "prometheus_image" {
  description = "Prometheus Docker image version"
  type        = string
  default     = "prom/prometheus:latest"
}

variable "prometheus_memory_limit" {
  description = "Memory limit for Prometheus container"
  type        = number
  default     = 512
}

variable "prometheus_config_path" {
  description = "Path to Prometheus configuration file"
  type        = string
  default     = "/root/traefik-setup/projects/monitoring/prometheus.yml"
}

variable "grafana_image" {
  description = "Grafana Docker image version"
  type        = string
  default     = "grafana/grafana:latest"
}

variable "grafana_memory_limit" {
  description = "Memory limit for Grafana container"
  type        = number
  default     = 512
}

variable "grafana_admin_password" {
  description = "Grafana admin password"
  type        = string
  sensitive   = true
  default     = "CHANGE_ME_GRAFANA_PASSWORD"
}

# Dashboard variables
variable "dashboard_image" {
  description = "Dashboard Docker image"
  type        = string
  default     = "dashboard:latest"
}

variable "dashboard_memory_limit" {
  description = "Memory limit for Dashboard container"
  type        = number
  default     = 256
}

variable "dashboard_build_context" {
  description = "Path to Dashboard build context"
  type        = string
  default     = "/root/traefik-setup/projects/dashboard"
}
