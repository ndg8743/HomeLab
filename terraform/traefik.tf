resource "docker_image" "traefik" {
  name         = var.traefik_image
  keep_locally = true
}

resource "docker_container" "traefik" {
  name  = "traefik"
  image = docker_image.traefik.image_id

  restart = "unless-stopped"

  # Network configuration
  networks_advanced {
    name = docker_network.traefik_public.name
  }

  # Port mappings
  ports {
    internal = 80
    external = 80
    protocol = "tcp"
  }

  ports {
    internal = 443
    external = 443
    protocol = "tcp"
  }

  # Volume mounts
  volumes {
    host_path      = "/var/run/docker.sock"
    container_path = "/var/run/docker.sock"
    read_only      = true
  }

  volumes {
    host_path      = var.traefik_config_path
    container_path = "/etc/traefik"
    read_only      = false
  }

  volumes {
    host_path      = var.acme_storage_path
    container_path = "/acme"
    read_only      = false
  }

  volumes {
    host_path      = var.traefik_logs_path
    container_path = "/var/log/traefik"
    read_only      = false
  }

  # Command line arguments
  command = [
    "--api.dashboard=${var.traefik_dashboard_enabled}",
    "--log.level=${var.traefik_log_level}",
    "--accesslog=true",
    "--accesslog.filepath=/var/log/traefik/access.log",
    "--accesslog.bufferingsize=100",
    "--providers.docker=true",
    "--providers.docker.exposedbydefault=false",
    "--providers.docker.network=${var.network_name}",
    "--providers.file.directory=/etc/traefik",
    "--providers.file.watch=true",
    "--entrypoints.web.address=:80",
    "--entrypoints.websecure.address=:443",
    "--entrypoints.web.http.redirections.entrypoint.to=websecure",
    "--entrypoints.web.http.redirections.entrypoint.scheme=https",
    "--certificatesresolvers.letsencrypt.acme.email=${var.email}",
    "--certificatesresolvers.letsencrypt.acme.storage=/acme/acme.json",
    "--certificatesresolvers.letsencrypt.acme.tlschallenge=true",
    "--certificatesresolvers.letsencrypt.acme.httpchallenge=true",
    "--certificatesresolvers.letsencrypt.acme.httpchallenge.entrypoint=web",
    "--metrics.prometheus=true",
    "--metrics.prometheus.addEntryPointsLabels=true",
    "--metrics.prometheus.addServicesLabels=true",
    "--global.sendAnonymousUsage=false"
  ]

  # Security options
  security_opts = [
    "no-new-privileges:true"
  ]

  # Resource limits
  memory = var.traefik_memory_limit

  # Healthcheck
  healthcheck {
    test     = ["CMD", "traefik", "healthcheck", "--ping"]
    interval = "30s"
    timeout  = "5s"
    retries  = 3
  }

  # Labels for Traefik dashboard
  labels {
    label = "traefik.enable"
    value = "true"
  }

  labels {
    label = "traefik.http.routers.dashboard.rule"
    value = "Host(`traefik.${var.domain}`)"
  }

  labels {
    label = "traefik.http.routers.dashboard.entrypoints"
    value = "websecure"
  }

  labels {
    label = "traefik.http.routers.dashboard.tls.certresolver"
    value = "letsencrypt"
  }

  labels {
    label = "traefik.http.routers.dashboard.service"
    value = "api@internal"
  }

  labels {
    label = "traefik.http.routers.dashboard.middlewares"
    value = "dashboard-auth"
  }

  labels {
    label = "traefik.http.middlewares.dashboard-auth.basicauth.users"
    value = "admin:$$apr1$$H6uskkkW$$IgXLP6ewTrSuBkTrqE8wj/"
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
    docker_network.traefik_public
  ]
}
