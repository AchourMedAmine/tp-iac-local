# --- Configuration Terraform et provider ---

terraform {
  required_version = ">= 1.0"

  required_providers {
    docker = {
      source  = "kreuzwerker/docker"
      version = "~> 3.0"
    }
  }

  # État local (terraform.tfstate). Le chemin peut être changé à l'init :
  # terraform init -backend-config="path=/chemin/terraform.tfstate"
  backend "local" {}
}

# Se connecte au démon Docker local (unix:///var/run/docker.sock par défaut)
provider "docker" {}

# --- 1. Base de données PostgreSQL ---

# Télécharge l'image depuis Docker Hub (conservée localement après destroy)
resource "docker_image" "postgres_image" {
  name         = "postgres:latest"
  keep_locally = true
}

resource "docker_container" "db_container" {
  name  = "tp-db-postgres"
  image = docker_image.postgres_image.image_id

  ports {
    internal = 5432
    external = var.db_port_external
  }

  # Configuration de la base via les variables d'environnement de l'image
  env = [
    "POSTGRES_USER=${var.db_user}",
    "POSTGRES_PASSWORD=${var.db_password}",
    "POSTGRES_DB=${var.db_name}",
  ]

  # Le conteneur n'est "healthy" que lorsque PostgreSQL accepte les connexions TCP
  healthcheck {
    test         = ["CMD-SHELL", "pg_isready -h 127.0.0.1 -U ${var.db_user} -d ${var.db_name}"]
    interval     = "5s"
    timeout      = "3s"
    retries      = 10
    start_period = "5s"
  }

  # Terraform attend l'état "healthy" avant de considérer la ressource créée
  wait         = true
  wait_timeout = 90
}

# --- 2. Application web (Nginx sur Alpine) ---

# Construit l'image à partir du Dockerfile_app local
resource "docker_image" "app_image" {
  name = "tp-web-app:latest"

  build {
    context    = path.module
    dockerfile = "Dockerfile_app"
  }

  # Reconstruit l'image si le Dockerfile change
  triggers = {
    dockerfile_hash = filesha1("${path.module}/Dockerfile_app")
  }
}

resource "docker_container" "app_container" {
  name  = "tp-app-web"
  image = docker_image.app_image.image_id

  ports {
    internal = 80
    external = var.app_port_external
  }

  # Dépendance explicite : l'application démarre après la base de données
  depends_on = [docker_container.db_container]
}
