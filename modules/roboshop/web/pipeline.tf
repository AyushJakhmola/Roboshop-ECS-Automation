resource "aws_iam_role" "codepipeline_role" {
  name = "code-pipeline-role-web"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "codepipeline.amazonaws.com"
      },
      "Action": "sts:AssumeRole"  
    }
  ]
}
EOF
}

resource "aws_iam_policy" "ecs-code-pipeline-role-policy" {
  name = "ecs-code-pipeline-role-policy"

  policy = <<EOF
{
  "Version": "2012-10-17",
"Statement": [{
			"Action": [
				"iam:PassRole"
			],
			"Resource": "*",
			"Effect": "Allow",
			"Condition": {
				"StringEqualsIfExists": {
					"iam:PassedToService": [
						"cloudformation.amazonaws.com",
						"elasticbeanstalk.amazonaws.com",
						"ec2.amazonaws.com",
						"ecs-tasks.amazonaws.com"
					]
				}
			}
		},
		{
			"Action": [
				"codecommit:CancelUploadArchive",
				"codecommit:GetBranch",
				"codecommit:GetCommit",
				"codecommit:GetRepository",
				"codecommit:GetUploadArchiveStatus",
				"codecommit:UploadArchive"
			],
			"Resource": "*",
			"Effect": "Allow"
		},
		{
			"Action": [
				"codedeploy:CreateDeployment",
				"codedeploy:GetApplication",
				"codedeploy:GetApplicationRevision",
				"codedeploy:GetDeployment",
				"codedeploy:GetDeploymentConfig",
				"codedeploy:RegisterApplicationRevision"
			],
			"Resource": "*",
			"Effect": "Allow"
		},
		{
			"Action": [
				"codestar-connections:UseConnection"
			],
			"Resource": "*",
			"Effect": "Allow"
		},
		{
			"Action": [
				"elasticbeanstalk:*",
				"ec2:*",
				"elasticloadbalancing:*",
				"autoscaling:*",
				"cloudwatch:*",
				"s3:*",
				"sns:*",
				"cloudformation:*",
				"rds:*",
				"sqs:*",
				"ecs:*"
			],
			"Resource": "*",
			"Effect": "Allow"
		},
		{
			"Action": [
				"lambda:InvokeFunction",
				"lambda:ListFunctions"
			],
			"Resource": "*",
			"Effect": "Allow"
		},
		{
			"Action": [
				"opsworks:CreateDeployment",
				"opsworks:DescribeApps",
				"opsworks:DescribeCommands",
				"opsworks:DescribeDeployments",
				"opsworks:DescribeInstances",
				"opsworks:DescribeStacks",
				"opsworks:UpdateApp",
				"opsworks:UpdateStack"
			],
			"Resource": "*",
			"Effect": "Allow"
		},
		{
			"Action": [
				"cloudformation:CreateStack",
				"cloudformation:DeleteStack",
				"cloudformation:DescribeStacks",
				"cloudformation:UpdateStack",
				"cloudformation:CreateChangeSet",
				"cloudformation:DeleteChangeSet",
				"cloudformation:DescribeChangeSet",
				"cloudformation:ExecuteChangeSet",
				"cloudformation:SetStackPolicy",
				"cloudformation:ValidateTemplate"
			],
			"Resource": "*",
			"Effect": "Allow"
		},
		{
			"Action": [
				"codebuild:BatchGetBuilds",
				"codebuild:StartBuild",
				"codebuild:BatchGetBuildBatches",
				"codebuild:StartBuildBatch"
			],
			"Resource": "*",
			"Effect": "Allow"
		},
		{
			"Effect": "Allow",
			"Action": [
				"devicefarm:ListProjects",
				"devicefarm:ListDevicePools",
				"devicefarm:GetRun",
				"devicefarm:GetUpload",
				"devicefarm:CreateUpload",
				"devicefarm:ScheduleRun"
			],
			"Resource": "*"
		},
		{
			"Effect": "Allow",
			"Action": [
				"servicecatalog:ListProvisioningArtifacts",
				"servicecatalog:CreateProvisioningArtifact",
				"servicecatalog:DescribeProvisioningArtifact",
				"servicecatalog:DeleteProvisioningArtifact",
				"servicecatalog:UpdateProduct"
			],
			"Resource": "*"
		},
		{
			"Effect": "Allow",
			"Action": [
				"cloudformation:ValidateTemplate"
			],
			"Resource": "*"
		},
		{
			"Effect": "Allow",
			"Action": [
				"ecr:DescribeImages"
			],
			"Resource": "*"
		},
		{
			"Effect": "Allow",
			"Action": [
				"states:DescribeExecution",
				"states:DescribeStateMachine",
				"states:StartExecution"
			],
			"Resource": "*"
		},
		{
			"Effect": "Allow",
			"Action": [
				"appconfig:StartDeployment",
				"appconfig:StopDeployment",
				"appconfig:GetDeployment"
			],
			"Resource": "*"
		},
		{
			"Effect": "Allow",
			"Resource": [
				"arn:aws:s3:::codepipeline-us-west-2-*"
			],
			"Action": [
				"s3:PutObject",
				"s3:GetObject",
				"s3:GetObjectVersion",
				"s3:GetBucketAcl",
				"s3:GetBucketLocation"
			]
		},
		{
			"Effect": "Allow",
			"Action": [
				"ecr:GetAuthorizationToken",
				"ecr:BatchCheckLayerAvailability",
				"ecr:GetDownloadUrlForLayer",
				"ecr:BatchGetImage",
				"logs:CreateLogStream",
				"logs:PutLogEvents",
				"ecr:PutImage",
				"ecr:InitiateLayerUpload",
				"ecr:UploadLayerPart",
				"ecr:CompleteLayerUpload"
			],
			"Resource": "*"
		},
		{
			"Sid": "STS",
			"Effect": "Allow",
			"Action": [
				"ecr:GetRegistryPolicy",
				"ecr:DescribeRegistry",
				"ecr:GetAuthorizationToken",
				"sts:*",
				"ecr:DeleteRegistryPolicy",
				"ecr:PutRegistryPolicy",
				"ecr:PutReplicationConfiguration"
			],
			"Resource": "*"
		},
		{
			"Effect": "Allow",
			"Action": [
				"s3:*",
				"s3-object-lambda:*"
			],
			"Resource": "*"
		},
		{
			"Effect": "Allow",
			"Action": [
				"codestar-connections:UseConnection"
			],
			"Resource": "*"
		}

	]
}
EOF
}


resource "aws_iam_role_policy_attachment" "ecs_codepipeline_attachment" {
  role       = aws_iam_role.codepipeline_role.name
  policy_arn = aws_iam_policy.ecs-code-pipeline-role-policy.arn
}

################# code pipeline for web

resource "aws_codepipeline" "code_pipeline" {
  name       = "code-pipeline-web"
  role_arn   = aws_iam_role.codepipeline_role.arn

  artifact_store {
    location = aws_s3_bucket.codepipeline_bucket.bucket
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
        FullRepositoryId       = "AyushJakhmola/robot-shop"
        BranchName     = "master"
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
        ProjectName = "code-build-project-web"
      }
    }
  }
  stage {
    name = "Deploy"

    action {
      category = "Deploy"
      configuration = {
        "ClusterName" = "ecs-robotshop-ec2"
        "ServiceName" = "web"
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

resource "aws_s3_bucket" "codepipeline_bucket" {
  bucket = "codepipeline-bucket-web"
}

resource "aws_s3_bucket_acl" "codepipeline_bucket_acl" {
  bucket = aws_s3_bucket.codepipeline_bucket.id
  acl    = "private"
}

resource "aws_s3_bucket_versioning" "versioning" {
  bucket = aws_s3_bucket.codepipeline_bucket.id
  versioning_configuration {
    status = "Enabled"
  }
}