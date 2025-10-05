resource "docker_image" "dashboard" {
  name         = var.dashboard_image
  keep_locally = true

  # Build the dashboard image if it doesn't exist
  build {
    context    = var.dashboard_build_context
    dockerfile = "Dockerfile"
  }
}

resource "docker_container" "dashboard" {
  name  = "dashboard"
  image = docker_image.dashboard.image_id

  restart = "unless-stopped"

  # Network configuration
  networks_advanced {
    name = docker_network.traefik_public.name
  }

  # Security options
  security_opts = [
    "no-new-privileges:true"
  ]

  # Resource limits
  memory = var.dashboard_memory_limit

  # Healthcheck
  healthcheck {
    test     = ["CMD", "wget", "--quiet", "--tries=1", "--spider", "http://localhost:80/", "||", "exit", "1"]
    interval = "30s"
    timeout  = "10s"
    retries  = 3
  }

  # Traefik labels
  labels {
    label = "traefik.enable"
    value = "true"
  }

  # HTTPS Router
  labels {
    label = "traefik.http.routers.dashboard.rule"
    value = "Host(`${var.domain}`) && PathPrefix(`/dashboard`)"
  }

  labels {
    label = "traefik.http.routers.dashboard.entrypoints"
    value = "websecure"
  }

  labels {
    label = "traefik.http.routers.dashboard.tls"
    value = "true"
  }

  labels {
    label = "traefik.http.routers.dashboard.tls.certresolver"
    value = "letsencrypt"
  }

  labels {
    label = "traefik.http.routers.dashboard.middlewares"
    value = "tinyauth@docker,dashboard-stripprefix,security-headers@file,compression@file,rate-limit-general@file"
  }

  # Service
  labels {
    label = "traefik.http.services.dashboard.loadbalancer.server.port"
    value = "80"
  }

  # StripPrefix Middleware
  labels {
    label = "traefik.http.middlewares.dashboard-stripprefix.stripprefix.prefixes"
    value = "/dashboard"
  }

  labels {
    label = "traefik.http.middlewares.dashboard-stripprefix.stripprefix.forceSlash"
    value = "false"
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
