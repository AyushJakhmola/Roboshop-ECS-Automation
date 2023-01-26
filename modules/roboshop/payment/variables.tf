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

    # amqp_host        = "rabitmq.robotshoptf"
    # cart_host        = "cart.robotshoptf"
    # catalogue_host   = "catalogue.robotshoptf"
    # payment_gateway = "https://paypal.com/"
    # shipping_host   = "shipping.robotshoptf"
    # user_host = "user.robotshoptf"
    # shop_payment_port = 8080

variable "amqp_host" {
  description = "amqp_host"
  default     = "rabitmq.robotshoptf"
}

variable "cart_host" {
  description = "cart_host"
  default     = "cart.robotshoptf"
}

variable "catalogue_host" {
  description = "catalogue_host"
  default     = "catalogue.robotshoptf"
}

variable "payment_gateway" {
  description = "payment_gateway"
  default     = "https://paypal.com/"
}

variable "user_host" {
  description = "user_host"
  default     = "user.robotshoptf"
}

variable "shipping_host" {
  description = "shipping_host"
  default     = "shipping.robotshoptf"
}

variable "shop_payment_port" {
  description = "shipping_host"
  default     = 8080
}

variable "taskdef_service_name" {
  description = "taskdef_service_name"
  default = "mysql"
}