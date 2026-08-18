resource "docker_network" "web_network" {
  name = var.network_name
}

resource "docker_image" "web_image" {
  name         = "iac-web-stack:local"
  keep_locally = true
}

resource "docker_container" "web" {
  name  = var.container_name
  image = docker_image.web_image.image_id

  restart = "unless-stopped"

  ports {
    internal = var.container_port
    external = var.host_port
  }

  networks_advanced {
    name = docker_network.web_network.name
  }

  healthcheck {
    test     = ["CMD", "wget", "--no-verbose", "--tries=1", "--spider", "http://localhost/"]
    interval = "30s"
    timeout  = "5s"
    retries  = 3
  }

  labels {
    label = "managed-by"
    value = "terraform"
  }

  labels {
    label = "project"
    value = "iac-web-stack"
  }

  labels {
    label = "environment"
    value = "local"
  }
}
