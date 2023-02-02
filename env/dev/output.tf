output "arn_image" {
  description = "arn_image"
  value       = module.ecs_repo.*.arn_image
}

output "ecr_repository" {
  description = "ecr_repository"
  value       = module.ecs_repo.*.ecr_repository
}

# output "secrets" {
#   description = "secrets"
#   value       = data.aws_secretsmanager_secret.by-arn
# }

output "example" {
  value = jsondecode(data.aws_secretsmanager_secret_version.secret-version.secret_string)["mongodb/url"]
  sensitive = true
}