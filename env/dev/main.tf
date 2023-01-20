
module "ecs_cluster" {
  source = "/home/ubuntu/Roboshop-ECS-Automation/modules/ecs"
  vpc_id = var.vpc_id
  subnet = var.subnet
}

module "mongodb" {
  source = "/home/ubuntu/Roboshop-ECS-Automation/modules/roboshop/mongodb"
  require_compatibility = var.require_compatibility
  vpc_id = var.vpc_id
  subnet = var.subnet
  cluster_arn = module.ecs_cluster.cluster_arn
  namespace = module.ecs_cluster.namespace
}

module "redis" {
  source = "/home/ubuntu/Roboshop-ECS-Automation/modules/roboshop/redis"
  require_compatibility = var.require_compatibility
  vpc_id = var.vpc_id
  subnet = var.subnet
  cluster_arn = module.ecs_cluster.cluster_arn
  namespace = module.ecs_cluster.namespace
}

module "rabbitmq" {
  source = "/home/ubuntu/Roboshop-ECS-Automation/modules/roboshop/rabbitmq"
  require_compatibility = var.require_compatibility
  vpc_id = var.vpc_id
  subnet = var.subnet
  cluster_arn = module.ecs_cluster.cluster_arn
  namespace = module.ecs_cluster.namespace
}

module "mysql" {
  source = "/home/ubuntu/Roboshop-ECS-Automation/modules/roboshop/mysql"
  require_compatibility = var.require_compatibility
  vpc_id = var.vpc_id
  subnet = var.subnet
  cluster_arn = module.ecs_cluster.cluster_arn
  namespace = module.ecs_cluster.namespace
}

module "user" {
  source = "/home/ubuntu/Roboshop-ECS-Automation/modules/roboshop/user"
  require_compatibility = var.require_compatibility
  vpc_id = var.vpc_id
  subnet = var.subnet
  cluster_arn = module.ecs_cluster.cluster_arn
  namespace = module.ecs_cluster.namespace
}

module "catalogue" {
  source = "/home/ubuntu/Roboshop-ECS-Automation/modules/roboshop/catalogue"
  require_compatibility = var.require_compatibility
  vpc_id = var.vpc_id
  subnet = var.subnet
  cluster_arn = module.ecs_cluster.cluster_arn
  namespace = module.ecs_cluster.namespace
}

module "cart" {
  source = "/home/ubuntu/Roboshop-ECS-Automation/modules/roboshop/cart"
  require_compatibility = var.require_compatibility
  vpc_id = var.vpc_id
  subnet = var.subnet
  cluster_arn = module.ecs_cluster.cluster_arn
  namespace = module.ecs_cluster.namespace
}

module "shipping" {
  source = "/home/ubuntu/Roboshop-ECS-Automation/modules/roboshop/shipping"
  require_compatibility = var.require_compatibility
  vpc_id = var.vpc_id
  subnet = var.subnet
  cluster_arn = module.ecs_cluster.cluster_arn
  namespace = module.ecs_cluster.namespace
}

module "payment" {
  source = "/home/ubuntu/Roboshop-ECS-Automation/modules/roboshop/payment"
  require_compatibility = var.require_compatibility
  vpc_id = var.vpc_id
  subnet = var.subnet
  cluster_arn = module.ecs_cluster.cluster_arn
  namespace = module.ecs_cluster.namespace
}

module "rating" {
  source = "/home/ubuntu/Roboshop-ECS-Automation/modules/roboshop/rating"
  require_compatibility = var.require_compatibility
  vpc_id = var.vpc_id
  subnet = var.subnet
  cluster_arn = module.ecs_cluster.cluster_arn
  namespace = module.ecs_cluster.namespace
}

module "dispatch" {
  source = "/home/ubuntu/Roboshop-ECS-Automation/modules/roboshop/dispatch"
  require_compatibility = var.require_compatibility
  vpc_id = var.vpc_id
  subnet = var.subnet
  cluster_arn = module.ecs_cluster.cluster_arn
  namespace = module.ecs_cluster.namespace
}

module "web" {
  source = "/home/ubuntu/Roboshop-ECS-Automation/modules/roboshop/web"
  require_compatibility = var.require_compatibility
  vpc_id = var.vpc_id
  subnet = var.subnet
  cluster_arn = module.ecs_cluster.cluster_arn
  namespace = module.ecs_cluster.namespace
}