################# code pipeline

resource "aws_codepipeline" "code_pipeline" {
  name       = var.code_pipeline_name
  role_arn   = var.pipeline_role_arn

  artifact_store {
    location = var.s3_bucket_name
    type     = "S3"
  }

  stage {
    name = "Source"
    action {
      name             = "Source"
      category         = "Source"
      owner            = "AWS"
      provider         = "CodeStarSourceConnection"
      version          = "1"
      input_artifacts  = []
      output_artifacts = ["SourceArtifact"]

      configuration = {
        # Owner      = var.github_owner
        ConnectionArn    = aws_codestarconnections_connection.code-pipeline-connection.arn
        FullRepositoryId       = var.repo_name
        BranchName     = var.branch_name
        # OAuthToken = var.github_token
      }
    }
  }
  stage {
    name = "Build"

    action {
      category = "Build"

      input_artifacts = [
        "SourceArtifact",
      ]
      name = "Build"
      output_artifacts = [
        "BuildArtifact",
      ]
      owner     = "AWS"
      provider  = "CodeBuild"
      run_order = 1
      version   = "1"
      configuration = {
        ProjectName = var.aws_codebuild_project_name
      }
    }
  }
  stage {
    name = "Deploy"

    action {
      category = "Deploy"
      configuration = {
        "ClusterName" = var.cluster_name
        "ServiceName" = var.service_name
        "FileName"    = "imageDefinitions.json"
        #"DeploymentTimeout" = "15"
      }
      input_artifacts = [
        "BuildArtifact",
      ]
      name             = "App_Deploy"
      output_artifacts = []
      owner            = "AWS"
      provider         = "ECS"
      run_order        = 1
      version          = "1"
    }
  }
}

resource "aws_codestarconnections_connection" "code-pipeline-connection" {
  name          = "codebuild-connection"
  provider_type = "GitHub"
}
