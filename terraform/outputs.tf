# ----------------------------------------------------
# 4C. OUTPUTS
# ----------------------------------------------------

output "frontend_ecr_uri" {
  description = "URI del Repositorio ECR del Frontend."
  value       = aws_ecr_repository.frontend.repository_url
}

output "alb_dns_name" {
  description = "DNS del Application Load Balancer."
  value       = aws_lb.main.dns_name
}

output "ecs_cluster_name" {
  description = "Nombre del cluster ECS."
  value       = aws_ecs_cluster.main.name
}