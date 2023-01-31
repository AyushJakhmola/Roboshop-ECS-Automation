output "codebuild_role_arn" {
  description = "arn of the codebuild role"
  value       = aws_iam_role.ecs-codebuild-role.arn
}

output "codepipeline_role_arn" {
  description = "arn of the codepipeline role"
  value       = aws_iam_role.codepipeline_role.arn
}

output "s3_bucket_name" {
  description = "s3_bucket_name"
  value       = aws_s3_bucket.codepipeline_bucket.bucket
}