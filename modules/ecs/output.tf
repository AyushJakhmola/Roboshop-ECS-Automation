output "cluster_arn" {
  description = "arn of the cluster"
  value       = module.ecs.cluster_arn
}

output "namespace" {
  description = "arn of the cluster"
  value       = aws_service_discovery_private_dns_namespace.robotshop_namespace.id
}