module "ecs_cluster" {
  source = "../../modules/ecs"
  # vpc_id = module.ecs_cluster.ecs_vpc_id
  # subnet = module.ecs_cluster.public_subnets
  ecs_namespace = var.ecs_namespace
  cluster_name = "ecs-robotshop-ec2"

#### vpc parameters ###
  vpc_name = "ecs-roboshop"
  vpc_cidr = "10.0.0.0/16"
  vpc_az = ["us-east-1a", "us-east-1b"]
  private_subnets_cidr = ["10.0.1.0/24", "10.0.2.0/24"]
  public_subnets_cidr = ["10.0.101.0/24", "10.0.102.0/24"]
}


#### module to create role for code build and code pipeline #### 
module "ecs_roles" {
  source = "../../modules/Roles"  
}

module "mongodb" {
  source = "../../modules/roboshop/mongodb"
  require_compatibility = var.require_compatibility
  vpc_id = module.ecs_cluster.ecs_vpc_id
  subnet = module.ecs_cluster.ecs_vpc_public_subnet_id
  cluster_arn = module.ecs_cluster.cluster_arn
  namespace = module.ecs_cluster.namespace_arn
  taskdef_service_name = "mongodb"
}

module "redis" {
  source = "../../modules/roboshop/redis"
  require_compatibility = var.require_compatibility
  vpc_id = module.ecs_cluster.ecs_vpc_id
  subnet = module.ecs_cluster.ecs_vpc_public_subnet_id
  cluster_arn = module.ecs_cluster.cluster_arn
  namespace = module.ecs_cluster.namespace_arn
  taskdef_service_name = "redis"
}

module "rabbitmq" {
  source = "../../modules/roboshop/rabbitmq"
  require_compatibility = var.require_compatibility
  vpc_id = module.ecs_cluster.ecs_vpc_id
  subnet = module.ecs_cluster.ecs_vpc_public_subnet_id
  cluster_arn = module.ecs_cluster.cluster_arn
  namespace = module.ecs_cluster.namespace_arn
  taskdef_service_name = "rabbitmq"
}

module "mysql" {
  source = "../../modules/roboshop/mysql"
  require_compatibility = var.require_compatibility
  vpc_id = module.ecs_cluster.ecs_vpc_id
  subnet = module.ecs_cluster.ecs_vpc_public_subnet_id
  cluster_arn = module.ecs_cluster.cluster_arn
  namespace = module.ecs_cluster.namespace_arn
  taskdef_service_name = "mysql"
}

##### microservice cart configurations #####

module "cart" {
  source = "../../modules/roboshop/services"
  ##cluster conf
  require_compatibility = var.require_compatibility
  vpc_id = module.ecs_cluster.ecs_vpc_id
  subnet = module.ecs_cluster.ecs_vpc_public_subnet_id
  cluster_arn = module.ecs_cluster.cluster_arn
  namespace = module.ecs_cluster.namespace_arn
  service_sg_name = "cart"
  ## application conf
  taskdef_service_name = "cart"
  container_definition = data.template_file.cart_json.rendered

  ## source conf 
  repo_name = "AyushJakhmola/robot-shop"
  branch_name = "master"

  ## build conf
  aws_codebuild_project_name = "code-build-project-cart"
  repo_location = "https://github.com/AyushJakhmola/robot-shop.git"
  build_role_arn = module.ecs_roles.codebuild_role_arn
  # buildspec = data.template_file.cart_buildspec.rendered
    AWS_DEFAULT_REGION = "us-east-1"
    IMAGE_REPO_NAME = "web"
    AWS_ACCOUNT_ID = "309017165673"
    CONTAINER_NAME = "web"
    BUILD_ENV = "dev"
    DIR = "web"

  ## deployment conf   
  pipeline_role_arn = module.ecs_roles.codepipeline_role_arn
  s3_bucket_name = module.ecs_roles.s3_bucket_name
  code_pipeline_name = "cart-pipeline"
  cluster_name = "ecs-robotshop-ec2"
  service_name = "cart"
}

data "template_file" "cart_json" {
  template   = file("${path.module}/taskdefinations/cart.json")

  vars = {
    catalogue_host   = local.catalogue_host
    redis_host = local.redis_host
    cart_server_port = local.cart_server_port
    cart_image = local.cart_image
  }
}

##### microservice user configurations #####

module "user" {
  source = "../../modules/roboshop/services"
  ##cluster conf
  require_compatibility = var.require_compatibility
  vpc_id = module.ecs_cluster.ecs_vpc_id
  subnet = module.ecs_cluster.ecs_vpc_public_subnet_id
  cluster_arn = module.ecs_cluster.cluster_arn
  namespace = module.ecs_cluster.namespace_arn
  service_sg_name = "user"

  ## application conf
  taskdef_service_name = "user"
  container_definition = data.template_file.user_json.rendered

  ## source conf 
  repo_name = "AyushJakhmola/robot-shop"
  branch_name = "master"

  ## build conf
  aws_codebuild_project_name = "code-build-project-user"
  repo_location = "https://github.com/AyushJakhmola/robot-shop.git"
  build_role_arn = module.ecs_roles.codebuild_role_arn
  # buildspec = data.template_file.cart_buildspec.rendered
    AWS_DEFAULT_REGION = "us-east-1"
    IMAGE_REPO_NAME = "user"
    AWS_ACCOUNT_ID = "309017165673"
    CONTAINER_NAME = "user"
    BUILD_ENV = "dev"
    DIR = "user"

  ## deployment conf   
  pipeline_role_arn = module.ecs_roles.codepipeline_role_arn
  s3_bucket_name = module.ecs_roles.s3_bucket_name
  code_pipeline_name = "user-pipeline"
  cluster_name = "ecs-robotshop-ec2"
  service_name = "user"
}

data "template_file" "user_json" {
  template   = file("${path.module}/taskdefinations/user.json")

  vars = {
    redis_url        = local.redis_host
    mongodb_url        = local.mongodb_url
    user_server_port = local.user_server_port
    user_image = local.user_image
  }
}

##### microservice catalogue configurations #####

module "catalogue" {
  source = "../../modules/roboshop/services"
  ##cluster conf
  require_compatibility = var.require_compatibility
  vpc_id = module.ecs_cluster.ecs_vpc_id
  subnet = module.ecs_cluster.ecs_vpc_public_subnet_id
  cluster_arn = module.ecs_cluster.cluster_arn
  namespace = module.ecs_cluster.namespace_arn
  service_sg_name = "catalogue"

  ## application conf
  taskdef_service_name = "catalogue"
  container_definition = data.template_file.user_json.rendered

  ## source conf 
  repo_name = "AyushJakhmola/robot-shop"
  branch_name = "master"

  ## build conf
  aws_codebuild_project_name = "code-build-project-catalogue"
  repo_location = "https://github.com/AyushJakhmola/robot-shop.git"
  build_role_arn = module.ecs_roles.codebuild_role_arn
  # buildspec = data.template_file.cart_buildspec.rendered
    AWS_DEFAULT_REGION = "us-east-1"
    IMAGE_REPO_NAME = "catalogue"
    AWS_ACCOUNT_ID = "309017165673"
    CONTAINER_NAME = "catalogue"
    BUILD_ENV = "dev"
    DIR = "catalogue"

  ## deployment conf   
  pipeline_role_arn = module.ecs_roles.codepipeline_role_arn
  s3_bucket_name = module.ecs_roles.s3_bucket_name
  code_pipeline_name = "catalogue-pipeline"
  cluster_name = "ecs-robotshop-ec2"
  service_name = "catalogue"
}

data "template_file" "catalogue_json" {
  template   = file("${path.module}/taskdefinations/catalogue.json")

  vars = {
    mongodb_url        = local.mongodb_url
    catalogue_server_port = local.catalogue_server_port
    catalogue_image = local.catalogue_image
  }
}

##### microservice shipping configurations #####

module "shipping" {
  source = "../../modules/roboshop/services"
  ##cluster conf
  require_compatibility = var.require_compatibility
  vpc_id = module.ecs_cluster.ecs_vpc_id
  subnet = module.ecs_cluster.ecs_vpc_public_subnet_id
  cluster_arn = module.ecs_cluster.cluster_arn
  namespace = module.ecs_cluster.namespace_arn
  service_sg_name = "shipping"
  ## application conf
  taskdef_service_name = "shipping"
  container_definition = data.template_file.user_json.rendered

  ## source conf 
  repo_name = "AyushJakhmola/robot-shop"
  branch_name = "master"

  ## build conf
  aws_codebuild_project_name = "code-build-project-shipping"
  repo_location = "https://github.com/AyushJakhmola/robot-shop.git"
  build_role_arn = module.ecs_roles.codebuild_role_arn
  # buildspec = data.template_file.cart_buildspec.rendered
    AWS_DEFAULT_REGION = "us-east-1"
    IMAGE_REPO_NAME = "shipping"
    AWS_ACCOUNT_ID = "309017165673"
    CONTAINER_NAME = "shipping"
    BUILD_ENV = "dev"
    DIR = "shipping"

  ## deployment conf   
  pipeline_role_arn = module.ecs_roles.codepipeline_role_arn
  s3_bucket_name = module.ecs_roles.s3_bucket_name
  code_pipeline_name = "shipping-pipeline"
  cluster_name = "ecs-robotshop-ec2"
  service_name = "shipping"
}

data "template_file" "shipping_json" {
  template   = file("${path.module}/taskdefinations/shipping.json")

  vars = {
    shipping_image = local.shipping_image
    cart_endpoint        = local.cart_endpoint
    catalogue_url   = local.catalogue_url
    db_host   = local.db_host  
  }
}

##### microservice payment configurations #####

module "payment" {
  source = "../../modules/roboshop/services"
  ##cluster conf
  require_compatibility = var.require_compatibility
  vpc_id = module.ecs_cluster.ecs_vpc_id
  subnet = module.ecs_cluster.ecs_vpc_public_subnet_id
  cluster_arn = module.ecs_cluster.cluster_arn
  namespace = module.ecs_cluster.namespace_arn
  service_sg_name = "payment"

  ## application conf
  taskdef_service_name = "payment"
  container_definition = data.template_file.user_json.rendered

  ## source conf 
  repo_name = "AyushJakhmola/robot-shop"
  branch_name = "master"

  ## build conf
  aws_codebuild_project_name = "code-build-project-payment"
  repo_location = "https://github.com/AyushJakhmola/robot-shop.git"
  build_role_arn = module.ecs_roles.codebuild_role_arn
  # buildspec = data.template_file.cart_buildspec.rendered
    AWS_DEFAULT_REGION = "us-east-1"
    IMAGE_REPO_NAME = "payment"
    AWS_ACCOUNT_ID = "309017165673"
    CONTAINER_NAME = "payment"
    BUILD_ENV = "dev"
    DIR = "payment"

  ## deployment conf   
  pipeline_role_arn = module.ecs_roles.codepipeline_role_arn
  s3_bucket_name = module.ecs_roles.s3_bucket_name
  code_pipeline_name = "payment-pipeline"
  cluster_name = "ecs-robotshop-ec2"
  service_name = "payment"
}

data "template_file" "payment_json" {
  template   = file("${path.module}/taskdefinations/payment.json")

  vars = {
    amqp_host        = local.amqp_host
    cart_host        = local.cart_endpoint
    catalogue_host   = local.catalogue_host
    payment_gateway = local.payment_gateway
    shipping_host   = local.shipping_host
    user_host = local.user_host
    shop_payment_port = local.shop_payment_port
    payment_image = local.payment_image
  }
}

##### microservice rating configurations #####

module "rating" {
  source = "../../modules/roboshop/services"
  ##cluster conf
  require_compatibility = var.require_compatibility
  vpc_id = module.ecs_cluster.ecs_vpc_id
  subnet = module.ecs_cluster.ecs_vpc_public_subnet_id
  cluster_arn = module.ecs_cluster.cluster_arn
  namespace = module.ecs_cluster.namespace_arn
  service_sg_name = "rating"

  ## application conf
  taskdef_service_name = "rating"
  container_definition = data.template_file.user_json.rendered

  ## source conf 
  repo_name = "AyushJakhmola/robot-shop"
  branch_name = "master"

  ## build conf
  aws_codebuild_project_name = "code-build-project-rating"
  repo_location = "https://github.com/AyushJakhmola/robot-shop.git"
  build_role_arn = module.ecs_roles.codebuild_role_arn
  # buildspec = data.template_file.cart_buildspec.rendered
    AWS_DEFAULT_REGION = "us-east-1"
    IMAGE_REPO_NAME = "rating"
    AWS_ACCOUNT_ID = "309017165673"
    CONTAINER_NAME = "rating"
    BUILD_ENV = "dev"
    DIR = "rating"

  ## deployment conf   
  pipeline_role_arn = module.ecs_roles.codepipeline_role_arn
  s3_bucket_name = module.ecs_roles.s3_bucket_name
  code_pipeline_name = "rating-pipeline"
  cluster_name = "ecs-robotshop-ec2"
  service_name = "rating"
}

data "template_file" "rating_json" {
  template   = file("${path.module}/taskdefinations/rating.json")

  vars = {
    rating_image = local.rating_image
    catalogue_url = local.catalogue_url
    pdo_url = local.pdo_url
  }
}

##### microservice dispatch configurations #####

module "dispatch" {
  source = "../../modules/roboshop/services"
  ##cluster conf
  require_compatibility = var.require_compatibility
  vpc_id = module.ecs_cluster.ecs_vpc_id
  subnet = module.ecs_cluster.ecs_vpc_public_subnet_id
  cluster_arn = module.ecs_cluster.cluster_arn
  namespace = module.ecs_cluster.namespace_arn
  service_sg_name = "dispatch"

  ## application conf
  taskdef_service_name = "dispatch"
  container_definition = data.template_file.user_json.rendered

  ## source conf 
  repo_name = "AyushJakhmola/robot-shop"
  branch_name = "master"

  ## build conf
  aws_codebuild_project_name = "code-build-project-dispatch"
  repo_location = "https://github.com/AyushJakhmola/robot-shop.git"
  build_role_arn = module.ecs_roles.codebuild_role_arn
  # buildspec = data.template_file.cart_buildspec.rendered
    AWS_DEFAULT_REGION = "us-east-1"
    IMAGE_REPO_NAME = "dispatch"
    AWS_ACCOUNT_ID = "309017165673"
    CONTAINER_NAME = "dispatch"
    BUILD_ENV = "dev"
    DIR = "dispatch"

  ## deployment conf   
  pipeline_role_arn = module.ecs_roles.codepipeline_role_arn
  s3_bucket_name = module.ecs_roles.s3_bucket_name
  code_pipeline_name = "dispatch-pipeline"
  cluster_name = "ecs-robotshop-ec2"
  service_name = "dispatch"
}

data "template_file" "dispatch_json" {
  template   = file("${path.module}/taskdefinations/dispatch.json")

  vars = {
    dispatch_image = local.dispatch_image
    amqp_host = local.amqp_host
  }
}


##### microservice web configurations #####

module "web" {
  source = "../../modules/roboshop/services"
  ##cluster conf
  require_compatibility = var.require_compatibility
  vpc_id = module.ecs_cluster.ecs_vpc_id
  subnet = module.ecs_cluster.ecs_vpc_public_subnet_id
  cluster_arn = module.ecs_cluster.cluster_arn
  namespace = module.ecs_cluster.namespace_arn
  service_sg_name = "web"

  ## application conf
  taskdef_service_name = "web"
  container_definition = data.template_file.user_json.rendered

  ## source conf 
  repo_name = "AyushJakhmola/robot-shop"
  branch_name = "master"

  ## build conf
  aws_codebuild_project_name = "code-build-project-web"
  repo_location = "https://github.com/AyushJakhmola/robot-shop.git"
  build_role_arn = module.ecs_roles.codebuild_role_arn
  # buildspec = data.template_file.cart_buildspec.rendered
    AWS_DEFAULT_REGION = "us-east-1"
    IMAGE_REPO_NAME = "web"
    AWS_ACCOUNT_ID = "309017165673"
    CONTAINER_NAME = "web"
    BUILD_ENV = "dev"
    DIR = "web"

  ## deployment conf   
  pipeline_role_arn = module.ecs_roles.codepipeline_role_arn
  s3_bucket_name = module.ecs_roles.s3_bucket_name
  code_pipeline_name = "web-pipeline"
  cluster_name = "ecs-robotshop-ec2"
  service_name = "web"
}

data "template_file" "web_json" {
  template   = file("${path.module}/taskdefinations/web.json")

  vars = {
    web_image = local.web_image
    catalogue_host = local.catalogue_host
    cart_host = local.cart_host
    payment_host = local.payment_host
    rating_host = "rating.${var.ecs_namespace}"
    shipping_host = "shipping.${var.ecs_namespace}"
    user_host = "user.${var.ecs_namespace}"
  }
}

module "ecs_repo" {
  source = "../../modules/Roles"  
  ecr_repo_name = "rs-catalogue"
}