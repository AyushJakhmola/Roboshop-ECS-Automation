
module "ecs_cluster" {
  source = "../../modules/ecs"
  # vpc_id = module.ecs_cluster.ecs_vpc_id
  # subnet = module.ecs_cluster.public_subnets
  ecs_namespace = var.ecs_namespace
}

module "mongodb" {
  source = "../../modules/roboshop/mongodb"
  require_compatibility = var.require_compatibility
  vpc_id = module.ecs_cluster.ecs_vpc_id
  subnet = module.ecs_cluster.ecs_vpc_public_subnet_id
  cluster_arn = module.ecs_cluster.cluster_arn
  namespace = module.ecs_cluster.namespace
  taskdef_service_name = "mongodb"
}

module "redis" {
  source = "../../modules/roboshop/redis"
  require_compatibility = var.require_compatibility
  vpc_id = module.ecs_cluster.ecs_vpc_id
  subnet = module.ecs_cluster.ecs_vpc_public_subnet_id
  cluster_arn = module.ecs_cluster.cluster_arn
  namespace = module.ecs_cluster.namespace
  taskdef_service_name = "redis"
}

module "rabbitmq" {
  source = "../../modules/roboshop/rabbitmq"
  require_compatibility = var.require_compatibility
  vpc_id = module.ecs_cluster.ecs_vpc_id
  subnet = module.ecs_cluster.ecs_vpc_public_subnet_id
  cluster_arn = module.ecs_cluster.cluster_arn
  namespace = module.ecs_cluster.namespace
  taskdef_service_name = "rabbitmq"
}

module "mysql" {
  source = "../../modules/roboshop/mysql"
  require_compatibility = var.require_compatibility
  vpc_id = module.ecs_cluster.ecs_vpc_id
  subnet = module.ecs_cluster.ecs_vpc_public_subnet_id
  cluster_arn = module.ecs_cluster.cluster_arn
  namespace = module.ecs_cluster.namespace
  taskdef_service_name = "mysql"
}

module "user" {
  source = "../../modules/roboshop/user"
  require_compatibility = var.require_compatibility
  vpc_id = module.ecs_cluster.ecs_vpc_id
  subnet = module.ecs_cluster.ecs_vpc_public_subnet_id
  cluster_arn = module.ecs_cluster.cluster_arn
  namespace = module.ecs_cluster.namespace
  taskdef_service_name = "user"
  redis_url        = "redis.${var.ecs_namespace}"
  mongodb_url        = "mongodb://robo:asdfghjkl123@mongodb.robotshopecs/admin"
  user_server_port = "8080"
}

module "catalogue" {
  source = "../../modules/roboshop/catalogue"
  require_compatibility = var.require_compatibility
  vpc_id = module.ecs_cluster.ecs_vpc_id
  subnet = module.ecs_cluster.ecs_vpc_public_subnet_id
  cluster_arn = module.ecs_cluster.cluster_arn
  namespace = module.ecs_cluster.namespace
  taskdef_service_name = "catalogue"
  catalogue_server_port = 8080
  mongodb_url      = "mongodb://robo:asdfghjkl123@mongodb.robotshopecs/admin"
}

module "cart" {
  source = "../../modules/roboshop/cart"
  require_compatibility = var.require_compatibility
  vpc_id = module.ecs_cluster.ecs_vpc_id
  subnet = module.ecs_cluster.ecs_vpc_public_subnet_id
  cluster_arn = module.ecs_cluster.cluster_arn
  namespace = module.ecs_cluster.namespace
  taskdef_service_name = "cart"
  catalogue_host   = "catalogue.${var.ecs_namespace}"
  redis_host = "redis.${var.ecs_namespace}"
  cart_server_port = 8080  
}

module "shipping" {
  source = "../../modules/roboshop/shipping"
  require_compatibility = var.require_compatibility
  vpc_id = module.ecs_cluster.ecs_vpc_id
  subnet = module.ecs_cluster.ecs_vpc_public_subnet_id
  cluster_arn = module.ecs_cluster.cluster_arn
  namespace = module.ecs_cluster.namespace
  taskdef_service_name = "shipping"
  cart_endpoint        = "cart.${var.ecs_namespace}"
  catalogue_url   = "catalogue.${var.ecs_namespace}"
  db_host   = "mysql:host=mysql.${var.ecs_namespace};dbname=ratings;charset=utf8mb4"  
}

module "payment" {
  source = "../../modules/roboshop/payment"
  require_compatibility = var.require_compatibility
  vpc_id = module.ecs_cluster.ecs_vpc_id
  subnet = module.ecs_cluster.ecs_vpc_public_subnet_id
  cluster_arn = module.ecs_cluster.cluster_arn
  namespace = module.ecs_cluster.namespace
  taskdef_service_name = "payment"
    amqp_host        = "rabitmq.${var.ecs_namespace}"
    cart_host        = "cart.${var.ecs_namespace}"
    catalogue_host   = "catalogue.${var.ecs_namespace}"
    payment_gateway = "https://paypal.com/"
    shipping_host   = "shipping.${var.ecs_namespace}"
    user_host = "user.${var.ecs_namespace}"
    shop_payment_port = 8080
}

module "rating" {
  source = "../../modules/roboshop/rating"
  require_compatibility = var.require_compatibility
  vpc_id = module.ecs_cluster.ecs_vpc_id
  subnet = module.ecs_cluster.ecs_vpc_public_subnet_id
  cluster_arn = module.ecs_cluster.cluster_arn
  namespace = module.ecs_cluster.namespace
  taskdef_service_name = "rating"
  catalogue_url = "catalogue.${var.ecs_namespace}"
  pdo_url = "mysql:host=mysql.${var.ecs_namespace};dbname=ratings;charset=utf8mb4"
}

module "dispatch" {
  source = "../../modules/roboshop/dispatch"
  require_compatibility = var.require_compatibility
  vpc_id = module.ecs_cluster.ecs_vpc_id
  subnet = module.ecs_cluster.ecs_vpc_public_subnet_id
  cluster_arn = module.ecs_cluster.cluster_arn
  namespace = module.ecs_cluster.namespace
  taskdef_service_name = "dispatch"
  amqp_host = "rebbitmq.${var.ecs_namespace}"
}

module "web" {
  source = "../../modules/roboshop/web"
  require_compatibility = var.require_compatibility
  vpc_id = module.ecs_cluster.ecs_vpc_id
  subnet = module.ecs_cluster.ecs_vpc_public_subnet_id
  cluster_arn = module.ecs_cluster.cluster_arn
  namespace = module.ecs_cluster.namespace
  taskdef_service_name = "web"
  cart_host = "cart.${var.ecs_namespace}"
  catalogue_host = "catalogue.${var.ecs_namespace}"
  payment_host = "payment.${var.ecs_namespace}"
  rating_host = "rating.${var.ecs_namespace}"
  shipping_host = "shipping.${var.ecs_namespace}"
  user_host = "user.${var.ecs_namespace}"

}