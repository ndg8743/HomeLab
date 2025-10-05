resource "docker_image" "portainer" {
  name         = var.portainer_image
  keep_locally = true
}

resource "docker_container" "portainer" {
  name  = "portainer"
  image = docker_image.portainer.image_id

  restart = "unless-stopped"

  # Network configuration
  networks_advanced {
    name = docker_network.traefik_public.name
  }

  # Volume mounts
  volumes {
    host_path      = "/var/run/docker.sock"
    container_path = "/var/run/docker.sock"
    read_only      = false
  }

  volumes {
    host_path      = var.portainer_data_path
    container_path = "/data"
    read_only      = false
  }

  # Security options
  security_opts = [
    "no-new-privileges:true"
  ]

  # Resource limits
  memory = var.portainer_memory_limit

  # Traefik labels
  labels {
    label = "traefik.enable"
    value = "true"
  }

  labels {
    label = "traefik.http.routers.portainer.rule"
    value = "Host(`portainer.${var.domain}`)"
  }

  labels {
    label = "traefik.http.routers.portainer.entrypoints"
    value = "websecure"
  }

  labels {
    label = "traefik.http.routers.portainer.tls.certresolver"
    value = "letsencrypt"
  }

  labels {
    label = "traefik.http.services.portainer.loadbalancer.server.port"
    value = "9000"
  }

  labels {
    label = "traefik.http.routers.portainer.middlewares"
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
