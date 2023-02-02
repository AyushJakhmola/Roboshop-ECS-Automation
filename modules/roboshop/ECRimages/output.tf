output "arn_image" {
  description = "arn_image"
  value       = module.ecr_image.*.image_uri[0]
}

output "ecr_repository" {
  description = "ecr_repository"
  value       = module.ecr_image.*.ecr_repository.name[0]
}