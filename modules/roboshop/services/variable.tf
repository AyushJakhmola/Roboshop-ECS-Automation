variable "vpc_id" {
  description = "vpc_id"
  default = "vpc-00dd3f4de32c1808f"
}

variable "namespace" {
  description = "namespace"
}

variable "service_launch_type" {
  description = "service_launch_type"
  default = "EC2"
}

variable "taskdef_service_name" {
  description = "taskdef_service_name"
  default = "cart"
}

variable "subnet" {
  description = "subnets to launch cluster instances"
  default     = ["subnet-0ff1131c7b697d72f", "subnet-0ff1131c7b697d72f"]
}

variable "require_compatibility" {
  description = "require_compatibility"
}

variable "cluster_arn" {
  description = "cluster_arn"
}

variable "container_definition" {
  description = "container_definition"
}

variable "repo_name" {
  description = "repository user/repo_name"
}

variable "branch_name" {
  description = "branch name"
}

variable "aws_codebuild_project_name" {
  description = "aws_codebuild_project_name"
}

variable "repo_location" {
  description = "repo_location"
}

variable "cluster_name" {
  description = "cluster_name"
}

variable "service_name" {
  description = "service_name"
}

variable "AWS_DEFAULT_REGION" {
  description = "AWS_DEFAULT_REGION"
}

variable "IMAGE_REPO_NAME" {
  description = "IMAGE_REPO_NAME"
}

variable "AWS_ACCOUNT_ID" {
  description = "AWS_ACCOUNT_ID"
}

variable "CONTAINER_NAME" {
  description = "CONTAINER_NAME"
}

variable "BUILD_ENV" {
  description = "BUILD_ENV"
}

variable "DIR" {
  description = "directory for docker file"
}

variable "build_role_arn" {
  description = "build_role_arn"
}

variable "pipeline_role_arn" {
  description = "pipeline_role_arn"
}

variable "s3_bucket_name" {
  description = "s3_bucket_name"
}

variable "service_sg_name" {
  description = "service_sg_name"
}

variable "code_pipeline_name" {
  description = "code_pipeline_name"
}
