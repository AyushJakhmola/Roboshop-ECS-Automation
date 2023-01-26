variable "require_compatibility" {
  default     = ["EC2"]
}

variable "vpc_id" {
  description = "vpc to launch cluster instances"

}

variable "subnet" {
  description = "subnets to launch cluster instances"
}

variable "cluster_arn" {
  description = "arn of cluster"
}

variable "namespace" {
  description = "namespace of route 53"
}

variable "taskdef_service_name" {
  description = "taskdef_service_name"
  default = "mongodb"
}