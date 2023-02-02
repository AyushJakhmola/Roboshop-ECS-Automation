module "ecr_image" {
  source            = "github.com/andreswebs/terraform-aws-ecr-image"
  ecr_namespace     = "robotshop"
  image_suffix      = var.ecr_repo_name
  image_source_path = "robot-shop/${var.dockerfile_directory}/"
}

