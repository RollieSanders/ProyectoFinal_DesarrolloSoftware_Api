# ----------------------------------------------------
# 4A. VARIABLES
# ----------------------------------------------------

# Proveedor de AWS
variable "aws_region" {
  description = "La región de AWS donde se desplegará la infraestructura."
  type        = string
  default     = "us-east-1" # Cambia esto a tu región preferida
}

# Configuración del Proyecto
variable "project_name" {
  description = "Nombre base para los recursos del proyecto."
  type        = string
  default     = "proyectofinal"
}

# Configuración de ECR
variable "frontend_repo_name" {
  description = "Nombre del repositorio ECR para el frontend (Vue.js)."
  type        = string
  default     = "proyectofinal-frontend"
}

variable "backend_repo_name" {
  description = "Nombre del repositorio ECR para el backend (Python)."
  type        = string
  default     = "proyectofinal-backend"
}

# Configuración de Red (VPC)
variable "vpc_cidr_block" {
  description = "Bloque CIDR para la VPC."
  type        = string
  default     = "10.0.0.0/16"
}

variable "public_subnet_cidrs" {
  description = "Bloques CIDR para las subredes públicas (mínimo 2)."
  type        = list(string)
  default     = ["10.0.1.0/24", "10.0.2.0/24"] 
}

# Configuración de Fargate/ECS
variable "fargate_cpu" {
  description = "CPU reservada para la tarea Fargate (ej: 256, 512, 1024)."
  type        = string
  default     = "512"
}

variable "fargate_memory" {
  description = "Memoria reservada para la tarea Fargate (ej: 512, 1024, 2048)."
  type        = string
  default     = "1024"
}