output "app_access_url" {
  description = "URL d'accès à l'application web."
  value       = "http://localhost:${docker_container.app_container.ports[0].external}"
}

output "db_container_name" {
  description = "Nom du conteneur de la base de données."
  value       = docker_container.db_container.name
}

output "db_connection" {
  description = "Chaîne de connexion PostgreSQL (sans le mot de passe)."
  value       = "postgresql://${var.db_user}@localhost:${var.db_port_external}/${var.db_name}"
}

output "db_password" {
  description = "Mot de passe de la base (lisible avec : terraform output -raw db_password)."
  value       = var.db_password
  sensitive   = true
}
