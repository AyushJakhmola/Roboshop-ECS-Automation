resource "aws_iam_role" "codepipeline_role" {
  name = "code-pipeline-role"

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