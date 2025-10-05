resource "docker_image" "prometheus" {
  name         = var.prometheus_image
  keep_locally = true
}

resource "docker_image" "grafana" {
  name         = var.grafana_image
  keep_locally = true
}

resource "docker_volume" "prometheus_data" {
  name = "prometheus-data"

  labels {
    label = "environment"
    value = var.environment
  }

  labels {
    label = "managed-by"
    value = "terraform"
  }
}

resource "docker_volume" "grafana_data" {
  name = "grafana-data"

  labels {
    label = "environment"
    value = var.environment
  }

  labels {
    label = "managed-by"
    value = "terraform"
  }
}

# Prometheus container
resource "docker_container" "prometheus" {
  name  = "prometheus"
  image = docker_image.prometheus.image_id

  restart = "unless-stopped"

  # Network configuration
  networks_advanced {
    name = docker_network.traefik_public.name
  }

  # Volume mounts
  volumes {
    host_path      = var.prometheus_config_path
    container_path = "/etc/prometheus/prometheus.yml"
    read_only      = true
  }

  volumes {
    volume_name    = docker_volume.prometheus_data.name
    container_path = "/prometheus"
    read_only      = false
  }

  # Command line arguments
  command = [
    "--config.file=/etc/prometheus/prometheus.yml",
    "--storage.tsdb.path=/prometheus"
  ]

  # Security options
  security_opts = [
    "no-new-privileges:true"
  ]

  # Resource limits
  memory = var.prometheus_memory_limit

  # Traefik labels
  labels {
    label = "traefik.enable"
    value = "true"
  }

  labels {
    label = "traefik.http.routers.prometheus.rule"
    value = "Host(`prometheus.${var.domain}`)"
  }

  labels {
    label = "traefik.http.routers.prometheus.entrypoints"
    value = "websecure"
  }

  labels {
    label = "traefik.http.routers.prometheus.tls.certresolver"
    value = "letsencrypt"
  }

  labels {
    label = "traefik.http.services.prometheus.loadbalancer.server.port"
    value = "9090"
  }

  # Apply TinyAuth and security middlewares
  labels {
    label = "traefik.http.routers.prometheus.middlewares"
    value = "tinyauth@docker,security-headers@file,compression@file,rate-limit-strict@file"
  }

  labels {
    label = "environment"
    value = var.environment
  }

  labels {
    label = "managed-by"
    value = "terraform"
  }

  depends_on = [
    docker_network.traefik_public,
    docker_container.traefik,
    docker_container.tinyauth
  ]
}

# Grafana container
resource "docker_container" "grafana" {
  name  = "grafana"
  image = docker_image.grafana.image_id

  restart = "unless-stopped"

  # Network configuration
  networks_advanced {
    name = docker_network.traefik_public.name
  }

  # Volume mounts
  volumes {
    volume_name    = docker_volume.grafana_data.name
    container_path = "/var/lib/grafana"
    read_only      = false
  }

  # Environment variables
  env = [
    "GF_SECURITY_ADMIN_PASSWORD=${var.grafana_admin_password}",
    "GF_USERS_ALLOW_SIGN_UP=false",
    "GF_SERVER_ROOT_URL=https://grafana.${var.domain}"
  ]

  # Security options
  security_opts = [
    "no-new-privileges:true"
  ]

  # Resource limits
  memory = var.grafana_memory_limit

  # Traefik labels
  labels {
    label = "traefik.enable"
    value = "true"
  }

  labels {
    label = "traefik.http.routers.grafana.rule"
    value = "Host(`grafana.${var.domain}`)"
  }

  labels {
    label = "traefik.http.routers.grafana.entrypoints"
    value = "websecure"
  }

  labels {
    label = "traefik.http.routers.grafana.tls.certresolver"
    value = "letsencrypt"
  }

  labels {
    label = "traefik.http.services.grafana.loadbalancer.server.port"
    value = "3000"
  }

  # Apply TinyAuth and security middlewares
  labels {
    label = "traefik.http.routers.grafana.middlewares"
    value = "tinyauth@docker,security-headers@file,compression@file,rate-limit-strict@file"
  }

  labels {
    label = "environment"
    value = var.environment
  }

  labels {
    label = "managed-by"
    value = "terraform"
  }

  depends_on = [
    docker_network.traefik_public,
    docker_container.traefik,
    docker_container.tinyauth
  ]
}
