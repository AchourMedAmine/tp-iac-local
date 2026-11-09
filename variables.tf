# --- Variables de la base de données (PostgreSQL) ---

variable "db_name" {
  description = "Nom de la base de données PostgreSQL."
  type        = string
  default     = "devops_db"
}

variable "db_user" {
  description = "Nom d'utilisateur PostgreSQL."
  type        = string
  default     = "devops_user"
}

variable "db_password" {
  description = "Mot de passe PostgreSQL (valeur de TP : en production, utiliser un secret)."
  type        = string
  default     = "newPAssword"
  sensitive   = true # masqué dans la sortie de plan/apply
}

variable "db_port_external" {
  description = "Port de l'hôte mappé au port 5432 du conteneur PostgreSQL."
  type        = number
  default     = 5432
}

# --- Variables de l'application ---

variable "app_port_external" {
  description = "Port de l'hôte mappé au port 80 du conteneur web."
  type        = number
  default     = 8080

  validation {
    condition     = var.app_port_external > 1024 && var.app_port_external < 65536
    error_message = "Le port externe doit être compris entre 1025 et 65535."
  }
}
