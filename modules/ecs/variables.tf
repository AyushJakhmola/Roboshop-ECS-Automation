# variable "vpc_id" {
#   description = "vpc to launch cluster instances"
#   default     = "vpc-015507e5299f6073c"
#   type        = string
# }

# variable "subnet" {
#   description = "subnets to launch cluster instances"
#   default     = ["subnet-00614134196ed093d", "subnet-064b22c31001b4c12"]
# }

variable "ecs_namespace" {
  description = "ecs_namespace"
  default     = "robotshop"
}

variable "vpc_name" {
  description = "vpc_name"
  default     = "ecs-roboshop"
}

variable "vpc_cidr" {
  description = "vpc_cidr"
  default     = "10.0.0.0/16"
}

variable "vpc_az" {
  description = "vpc_az"
  default     = ["us-east-1a", "us-east-1b"]
}

variable "private_subnets_cidr" {
  description = "private_subnets"
  default     = ["10.0.1.0/24", "10.0.2.0/24"]
}

variable "public_subnets_cidr" {
  description = "public_subnets"
  default     = ["10.0.101.0/24", "10.0.102.0/24"]
}

variable "min_size" {
  description = "min_size"
  default     = 0
}

variable "max_size" {
  description = "max_size"
  default     = 7
}

variable "desired_capacity" {
  description = "desired_capacity"
  default     = 7
}

variable "cluster_instance_image_id" {
  description = "cluster_instance_image_id"
  default     = "ami-05e7fa5a3b6085a75"
}

variable "cluster_instance_type" {
  description = "cluster_instance_type"
  default     =  "t3a.medium"
}

variable "instance_key_name" {
  description = "instance_key_name"
  default     =  "ayush-squareops"
}

variable "instance_volume_size" {
  description = "volume_size"
  default     =  30
}

variable "instance_volume_type" {
  description = "volume_type"
  default     =  "gp2"
}

variable "cluster_name" {
  description = "cluster_name"
}
