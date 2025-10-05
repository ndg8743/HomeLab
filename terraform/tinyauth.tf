resource "docker_image" "tinyauth" {
  name         = var.tinyauth_image
  keep_locally = true
}

resource "docker_volume" "tinyauth_data" {
  name = "tinyauth_data"

  labels {
    label = "environment"
    value = var.environment
  }

  labels {
    label = "managed-by"
    value = "terraform"
  }
}

resource "docker_container" "tinyauth" {
  name  = "tinyauth"
  image = docker_image.tinyauth.image_id

  restart = "unless-stopped"

  # Network configuration
  networks_advanced {
    name = docker_network.traefik_public.name
  }

  # Volume mounts
  volumes {
    volume_name    = docker_volume.tinyauth_data.name
    container_path = "/data"
    read_only      = false
  }

  # Command line arguments for TinyAuth configuration
  command = [
    "--app-url=https://auth.${var.domain}",
    "--secret=${var.tinyauth_secret}",
    "--google-client-id=${var.google_client_id}",
    "--google-client-secret=${var.google_client_secret}",
    "--cookie-secure=true"
  ]

  # Security options
  security_opts = [
    "no-new-privileges:true"
  ]

  # Resource limits
  memory = var.tinyauth_memory_limit

  # Healthcheck
  healthcheck {
    test     = ["CMD", "wget", "--quiet", "--tries=1", "--spider", "http://localhost:3000/health", "||", "exit", "1"]
    interval = "30s"
    timeout  = "10s"
    retries  = 3
  }

  # Traefik labels for TinyAuth UI
  labels {
    label = "traefik.enable"
    value = "true"
  }

  labels {
    label = "traefik.http.routers.tinyauth.rule"
    value = "Host(`auth.${var.domain}`)"
  }

  labels {
    label = "traefik.http.routers.tinyauth.entrypoints"
    value = "websecure"
  }

  labels {
    label = "traefik.http.routers.tinyauth.tls.certresolver"
    value = "letsencrypt"
  }

  labels {
    label = "traefik.http.services.tinyauth.loadbalancer.server.port"
    value = "3000"
  }

  # Apply security middlewares to TinyAuth itself
  labels {
    label = "traefik.http.routers.tinyauth.middlewares"
    value = "security-headers@file,compression@file"
  }

  # ForwardAuth middleware definition
  labels {
    label = "traefik.http.middlewares.tinyauth.forwardauth.address"
    value = "http://tinyauth:3000/api/auth/traefik"
  }

  labels {
    label = "traefik.http.middlewares.tinyauth.forwardauth.authResponseHeaders"
    value = "X-Forwarded-User"
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
    docker_container.traefik
  ]
}
