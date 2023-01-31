output "cluster_arn" {
  description = "arn of the cluster"
  value       = module.ecs.cluster_arn
}

output "namespace_arn" {
  description = "arn of the cluster"
  value       = aws_service_discovery_private_dns_namespace.robotshop_namespace.id
}

output "ecs_vpc_id" {
  description = "arn of the cluster"
  value       = module.vpc.vpc_id
}

output "ecs_vpc_public_subnet_id" {
  description = "arn of the cluster"
  value       = module.vpc.public_subnets
}