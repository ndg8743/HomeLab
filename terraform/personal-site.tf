resource "docker_image" "personalsite" {
  name         = var.personalsite_image
  keep_locally = true
}

resource "docker_container" "personalsite" {
  name  = "personalsite"
  image = docker_image.personalsite.image_id

  restart = "unless-stopped"

  # Network configuration
  networks_advanced {
    name = docker_network.traefik_public.name
  }

  # Environment variables
  env = [
    "NODE_ENV=production"
  ]

  # Security options
  security_opts = [
    "no-new-privileges:true"
  ]

  # Resource limits
  memory = var.personalsite_memory_limit

  # Healthcheck
  healthcheck {
    test     = ["CMD", "wget", "--quiet", "--tries=1", "--spider", "http://localhost:3000/health", "||", "exit", "1"]
    interval = "30s"
    timeout  = "10s"
    retries  = 3
  }

  # Traefik labels
  labels {
    label = "traefik.enable"
    value = "true"
  }

  labels {
    label = "traefik.http.routers.personalsite.rule"
    value = "Host(`${var.domain}`) || Host(`www.${var.domain}`)"
  }

  labels {
    label = "traefik.http.routers.personalsite.entrypoints"
    value = "websecure"
  }

  labels {
    label = "traefik.http.routers.personalsite.tls.certresolver"
    value = "letsencrypt"
  }

  labels {
    label = "traefik.http.services.personalsite.loadbalancer.server.port"
    value = "3000"
  }

  labels {
    label = "traefik.http.routers.personalsite.middlewares"
    value = "personalsite-security,personalsite-compress,personalsite-ratelimit"
  }

  # Security headers middleware
  labels {
    label = "traefik.http.middlewares.personalsite-security.headers.stsSeconds"
    value = "31536000"
  }

  labels {
    label = "traefik.http.middlewares.personalsite-security.headers.stsIncludeSubdomains"
    value = "true"
  }

  labels {
    label = "traefik.http.middlewares.personalsite-security.headers.stsPreload"
    value = "true"
  }

  labels {
    label = "traefik.http.middlewares.personalsite-security.headers.forceSTSHeader"
    value = "true"
  }

  labels {
    label = "traefik.http.middlewares.personalsite-security.headers.frameDeny"
    value = "true"
  }

  labels {
    label = "traefik.http.middlewares.personalsite-security.headers.contentTypeNosniff"
    value = "true"
  }

  labels {
    label = "traefik.http.middlewares.personalsite-security.headers.browserXssFilter"
    value = "true"
  }

  labels {
    label = "traefik.http.middlewares.personalsite-security.headers.referrerPolicy"
    value = "strict-origin-when-cross-origin"
  }

  # Compression middleware
  labels {
    label = "traefik.http.middlewares.personalsite-compress.compress"
    value = "true"
  }

  # Rate limiting middleware
  labels {
    label = "traefik.http.middlewares.personalsite-ratelimit.ratelimit.average"
    value = "100"
  }

  labels {
    label = "traefik.http.middlewares.personalsite-ratelimit.ratelimit.burst"
    value = "50"
  }

  # WWW redirect middleware
  labels {
    label = "traefik.http.middlewares.personalsite-redirect-www.redirectregex.regex"
    value = "^https://www\\.(.+)"
  }

  labels {
    label = "traefik.http.middlewares.personalsite-redirect-www.redirectregex.replacement"
    value = "https://$${1}"
  }

  labels {
    label = "traefik.http.middlewares.personalsite-redirect-www.redirectregex.permanent"
    value = "true"
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
