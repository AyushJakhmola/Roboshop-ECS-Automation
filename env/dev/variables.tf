variable "require_compatibility" {
  default     = ["EC2"]
}

# variable "vpc_id" {
#   description = "vpc to launch cluster instances"
#   default     = module.ecs_cluster.ecs_vpc_id
# }

# variable "subnet" {
#   description = "subnets to launch cluster instances"
#   default     = module.ecs_cluster.public_subnets
# }

variable "ecs_namespace" {
  description = "ecs_namespace"
  default     = "ns-fracdfzdvoz7pk5s"
}


