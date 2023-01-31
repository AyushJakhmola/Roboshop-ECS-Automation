module "ecr_repo" {
  source = "terraform-aws-modules/ecr/aws"

  repository_name = var.ecr_repo_name

#   repository_read_write_access_arns = ["arn:aws:iam::012345678901:role/terraform"]
  repository_lifecycle_policy = jsonencode({
    rules = [
      {
        rulePriority = 1,
        description  = "Keep last 30 images",
        selection = {
          tagStatus     = "untagged",
        #   tagPrefixList = ["v"],
          countType     = "imageCountMoreThan",
          countNumber   = 30
        },
        action = {
          type = "expire"
        }
      }
    ]
  })

  tags = {
    Terraform   = "true"
    Environment = "dev"
  }
}

# module "ecr_image" {
#   source = "github.com/byu-oit/terraform-aws-ecr-image?ref=v1.0.1"
#   dockerfile_dir = "."
#   ecr_repository_url = module.ecr_repo.repository_url
# }

