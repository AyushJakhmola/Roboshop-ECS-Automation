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
  default     = "robotahoptf"
}
