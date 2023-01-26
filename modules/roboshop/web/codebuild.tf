resource "aws_iam_role" "ecs-codebuild-role" {
  name = "ecs-code-build"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "codebuild.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
}

resource "aws_iam_policy" "ecs-code-build-role-policy" {

  policy = <<POLICY
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Resource": [
                "*"
            ],
            "Action": [
                "logs:CreateLogGroup",
                "logs:CreateLogStream",
                "logs:PutLogEvents"
            ]
        },
        {
            "Effect": "Allow",
            "Resource": [
                "*"
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
                "codebuild:CreateReportGroup",
                "codebuild:CreateReport",
                "codebuild:UpdateReport",
                "codebuild:BatchPutTestCases",
                "codebuild:BatchPutCodeCoverages"
            ],
            "Resource": [
                "*"
            ]
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
            "Sid": "ECRRepo",
            "Effect": "Allow",
            "Action": "ecr:*",
            "Resource": "*"
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
        }
    ]
}
POLICY
}


resource "aws_iam_role_policy_attachment" "ecs_codebuild_attachment" {
  role       = aws_iam_role.ecs-codebuild-role.name
  policy_arn = aws_iam_policy.ecs-code-build-role-policy.arn
}


resource "aws_codebuild_project" "web-app" {
  name          = "code-build-project-web"
  description   = "test_codebuild_project"
  build_timeout = "5"
  service_role  = aws_iam_role.ecs-codebuild-role.arn

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
    buildspec = file("${path.module}/buildspec.yml")
    type            = "GITHUB"
    location        = "https://github.com/AyushJakhmola/robot-shop.git"
    git_clone_depth = 1

    git_submodules_config {
      fetch_submodules = true
    }
  }
}