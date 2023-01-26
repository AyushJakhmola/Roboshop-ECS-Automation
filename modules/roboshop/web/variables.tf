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


variable "cart_host" {
  description = "cart_host"
  default     = "cart.robotshoptf"
}

variable "catalogue_host" {
  description = "catalogue_host"
  default     = "catalogue.robotshoptf"
}

variable "payment_host" {
  description = "payment_host"
  default     = "payment.robotshoptf"
}

variable "rating_host" {
  description = "rating_host"
  default     = "rating.robotshoptf"
}

variable "shipping_host" {
  description = "shipping_host"
  default     = "shipping.robotshoptf"
}

variable "user_host" {
  description = "user_host"
  default     = "user.robotshoptf"
}

variable "taskdef_service_name" {
  description = "taskdef_service_name"
  default = "web"
}