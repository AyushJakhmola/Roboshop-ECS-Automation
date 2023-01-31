resource "aws_codebuild_project" "web-app" {
  name          = var.aws_codebuild_project_name
  description   = "codebuild_project"
  build_timeout = "5"
  service_role  = var.build_role_arn

  artifacts {
    type = "NO_ARTIFACTS"
  }

  environment {
    compute_type                = "BUILD_GENERAL1_SMALL"
    image                       = "aws/codebuild/standard:5.0"
    type                        = "LINUX_CONTAINER"
    image_pull_credentials_type = "CODEBUILD"
    privileged_mode = true
  }

  logs_config {
    cloudwatch_logs {
      status = "ENABLED"
    }
  }

  source {
    buildspec = data.template_file.cart_buildspec.rendered
    type            = "GITHUB"
    location        = var.repo_location
    git_clone_depth = 1

    git_submodules_config {
      fetch_submodules = true
    }
  }
}

data "template_file" "cart_buildspec" {
  template   = file("${path.module}/buildspecfiles/buildspec.yml")

  vars = {
    AWS_DEFAULT_REGION = var.AWS_DEFAULT_REGION
    IMAGE_REPO_NAME = var.IMAGE_REPO_NAME
    AWS_ACCOUNT_ID = var.AWS_ACCOUNT_ID
    CONTAINER_NAME = var.CONTAINER_NAME
    BUILD_ENV = var.BUILD_ENV
    DIR = var.DIR
  }
}