variable "require_compatibility" {
  default     = ["EC2"]
}

variable "vpc_id" {
  description = "vpc to launch cluster instances"
  default     = "vpc-015507e5299f6073c"
  type        = string
}

variable "subnet" {
  description = "subnets to launch cluster instances"
  default     = ["subnet-00614134196ed093d", "subnet-064b22c31001b4c12"]
}

variable "cluster_arn" {
  description = "arn of cluster"
}

variable "namespace" {
  description = "namespace of route 53"
}

variable "catalogue_server_port" {
  description = "catalogue server port"
  default     = 8080
}

variable "mongodb_url" {
  description = "catalogue host"
  default        = "mongodb://robo:asdfghjkl123@mongodb.robotshoptf/admin"
}

variable "taskdef_service_name" {
  description = "taskdef_service_name"
  default = "cart"
}