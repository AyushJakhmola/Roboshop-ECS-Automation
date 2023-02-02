module "ecs_cluster" {
  source = "../../modules/ecs"
  depends_on = [module.ecs_repo]
  # vpc_id = module.ecs_cluster.ecs_vpc_id
  # subnet = module.ecs_cluster.public_subnets
  ecs_namespace = var.ecs_namespace
  cluster_name = local.ecs_cluster_name

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
  mongodb_image_uri = module.ecs_repo[0].arn_image
  cloudwatch_log_group_name = "/ecs/mongodb"
}

module "redis" {
  source = "../../modules/roboshop/redis"
  require_compatibility = var.require_compatibility
  vpc_id = module.ecs_cluster.ecs_vpc_id
  subnet = module.ecs_cluster.ecs_vpc_public_subnet_id
  cluster_arn = module.ecs_cluster.cluster_arn
  namespace = module.ecs_cluster.namespace_arn
  taskdef_service_name = "redis"
  redis_image_uri = "309017165673.dkr.ecr.us-east-1.amazonaws.com/public:redis"
}

module "rabbitmq" {
  source = "../../modules/roboshop/rabbitmq"
  require_compatibility = var.require_compatibility
  vpc_id = module.ecs_cluster.ecs_vpc_id
  subnet = module.ecs_cluster.ecs_vpc_public_subnet_id
  cluster_arn = module.ecs_cluster.cluster_arn
  namespace = module.ecs_cluster.namespace_arn
  taskdef_service_name = "rabbitmq"
  rabbitmq_image_uri = "309017165673.dkr.ecr.us-east-1.amazonaws.com/public:rabbitmq"
}

module "mysql" {
  source = "../../modules/roboshop/mysql"
  require_compatibility = var.require_compatibility
  vpc_id = module.ecs_cluster.ecs_vpc_id
  subnet = module.ecs_cluster.ecs_vpc_public_subnet_id
  cluster_arn = module.ecs_cluster.cluster_arn
  namespace = module.ecs_cluster.namespace_arn
  taskdef_service_name = "mysql"
  mysql_image_uri = module.ecs_repo[1].arn_image
}

##### microservice cart configurations #####

module "cart" {
  source = "../../modules/roboshop/services"
  depends_on = [module.catalogue, module.redis]
  ##cluster conf
  require_compatibility = var.require_compatibility
  vpc_id = module.ecs_cluster.ecs_vpc_id
  subnet = module.ecs_cluster.ecs_vpc_public_subnet_id
  cluster_arn = module.ecs_cluster.cluster_arn
  namespace = module.ecs_cluster.namespace_arn
  service_sg_name = local.cart_container_name
  ## application conf
  taskdef_service_name = local.cart_container_name
  container_definition = data.template_file.cart_json.rendered
  cloudwatch_log_group_name = "/ecs/${local.cart_container_name}"

  ## source conf 
  repo_name = local.repo_name
  branch_name = local.branch_name

  ## build conf
  aws_codebuild_project_name = "code-build-project-cart"
  repo_location = local.repo_location
  build_role_arn = module.ecs_roles.codebuild_role_arn
  # buildspec = data.template_file.cart_buildspec.rendered
    AWS_DEFAULT_REGION = local.region
    IMAGE_REPO_NAME = module.ecs_repo[2].ecr_repository
    AWS_ACCOUNT_ID = local.acc_id
    CONTAINER_NAME = local.cart_container_name
    BUILD_ENV = "dev"
    DIR = "cart"

  ## deployment conf   
  pipeline_role_arn = module.ecs_roles.codepipeline_role_arn
  s3_bucket_name = module.ecs_roles.s3_bucket_name
  code_pipeline_name = "cart-pipeline"
  cluster_name = local.ecs_cluster_name
  service_name = local.cart_container_name
}

data "template_file" "cart_json" {
  template   = file("${path.module}/taskdefinations/cart.json")

  vars = {
    log_group = "/ecs/${local.cart_container_name}"
    region = local.region
    catalogue_host   = local.catalogue_host
    redis_host = local.redis_host
    cart_server_port = local.cart_server_port
    cart_image = module.ecs_repo[2].arn_image
    container_name = local.cart_container_name
  }
}

#### microservice user configurations #####

module "user" {
  source = "../../modules/roboshop/services"
  depends_on = [module.mongodb, module.redis]
  ##cluster conf
  require_compatibility = var.require_compatibility
  vpc_id = module.ecs_cluster.ecs_vpc_id
  subnet = module.ecs_cluster.ecs_vpc_public_subnet_id
  cluster_arn = module.ecs_cluster.cluster_arn
  namespace = module.ecs_cluster.namespace_arn
  service_sg_name = local.user_container_name

  ## application conf
  taskdef_service_name = local.user_container_name
  container_definition = data.template_file.user_json.rendered
  cloudwatch_log_group_name = "/ecs/${local.user_container_name}"

  ## source conf 
  repo_name = local.repo_name
  branch_name = local.branch_name

  ## build conf
  aws_codebuild_project_name = "code-build-project-user"
  repo_location = local.repo_location
  build_role_arn = module.ecs_roles.codebuild_role_arn
  # buildspec = data.template_file.cart_buildspec.rendered
    AWS_DEFAULT_REGION = local.region
    IMAGE_REPO_NAME = module.ecs_repo[3].ecr_repository
    AWS_ACCOUNT_ID = local.acc_id
    CONTAINER_NAME = local.user_container_name
    BUILD_ENV = "dev"
    DIR = "user"

  ## deployment conf   
  pipeline_role_arn = module.ecs_roles.codepipeline_role_arn
  s3_bucket_name = module.ecs_roles.s3_bucket_name
  code_pipeline_name = "user-pipeline"
  cluster_name = local.ecs_cluster_name
  service_name = local.user_container_name
}

data "template_file" "user_json" {
  template   = file("${path.module}/taskdefinations/user.json")

  vars = {
    redis_url        = local.redis_host
    mongodb_url        = local.mongodb_url
    user_server_port = local.user_server_port
    user_image = module.ecs_repo[3].arn_image
    log_group = "/ecs/${local.user_container_name}"
    region = local.region
    container_name = local.user_container_name
  }
}

##### microservice catalogue configurations #####

module "catalogue" {
  source = "../../modules/roboshop/services"
  depends_on = [module.mongodb]
  ##cluster conf
  require_compatibility = var.require_compatibility
  vpc_id = module.ecs_cluster.ecs_vpc_id
  subnet = module.ecs_cluster.ecs_vpc_public_subnet_id
  cluster_arn = module.ecs_cluster.cluster_arn
  namespace = module.ecs_cluster.namespace_arn
  service_sg_name = local.catalogue_container_name

  ## application conf
  taskdef_service_name = local.catalogue_container_name
  container_definition = data.template_file.catalogue_json.rendered
  cloudwatch_log_group_name = "/ecs/${local.catalogue_container_name}"

  ## source conf 
  repo_name = local.repo_name
  branch_name = local.branch_name

  ## build conf
  aws_codebuild_project_name = "code-build-project-catalogue"
  repo_location = local.repo_location
  build_role_arn = module.ecs_roles.codebuild_role_arn
  # buildspec = data.template_file.cart_buildspec.rendered
    AWS_DEFAULT_REGION = local.region
    IMAGE_REPO_NAME = module.ecs_repo[4].ecr_repository
    AWS_ACCOUNT_ID = local.acc_id
    CONTAINER_NAME = local.catalogue_container_name
    BUILD_ENV = "dev"
    DIR = "catalogue"

  ## deployment conf   
  pipeline_role_arn = module.ecs_roles.codepipeline_role_arn
  s3_bucket_name = module.ecs_roles.s3_bucket_name
  code_pipeline_name = "catalogue-pipeline"
  cluster_name = local.ecs_cluster_name
  service_name = local.catalogue_container_name
}

data "template_file" "catalogue_json" {
  template   = file("${path.module}/taskdefinations/catalogue.json")

  vars = {
    # mongodb_url        = local.mongodb_url
    mongodb_url = jsondecode(data.aws_secretsmanager_secret_version.secret-version.secret_string)["mongodb/url"]
    catalogue_server_port = local.catalogue_server_port
    catalogue_image = module.ecs_repo[4].arn_image
    log_group = "/ecs/${local.catalogue_container_name}"
    region = local.region
    container_name = local.catalogue_container_name
  }
}

##### microservice shipping configurations #####

module "shipping" {
  source = "../../modules/roboshop/services"
  depends_on = [module.catalogue, module.cart, module.mysql]
  ##cluster conf
  require_compatibility = var.require_compatibility
  vpc_id = module.ecs_cluster.ecs_vpc_id
  subnet = module.ecs_cluster.ecs_vpc_public_subnet_id
  cluster_arn = module.ecs_cluster.cluster_arn
  namespace = module.ecs_cluster.namespace_arn
  service_sg_name = local.shipping_container_name
  ## application conf
  taskdef_service_name = local.shipping_container_name
  container_definition = data.template_file.user_json.rendered
  cloudwatch_log_group_name = "/ecs/${local.shipping_container_name}"

  ## source conf 
  repo_name = local.repo_name
  branch_name = "master"

  ## build conf
  aws_codebuild_project_name = "code-build-project-shipping"
  repo_location = local.repo_location
  build_role_arn = module.ecs_roles.codebuild_role_arn
  # buildspec = data.template_file.cart_buildspec.rendered
    AWS_DEFAULT_REGION = local.region
    IMAGE_REPO_NAME = module.ecs_repo[5].ecr_repository
    AWS_ACCOUNT_ID = local.acc_id
    CONTAINER_NAME = local.shipping_container_name
    BUILD_ENV = "dev"
    DIR = "shipping"

  ## deployment conf   
  pipeline_role_arn = module.ecs_roles.codepipeline_role_arn
  s3_bucket_name = module.ecs_roles.s3_bucket_name
  code_pipeline_name = "shipping-pipeline"
  cluster_name = local.ecs_cluster_name
  service_name = local.shipping_container_name
}

data "template_file" "shipping_json" {
  template   = file("${path.module}/taskdefinations/shipping.json")

  vars = {
    shipping_image = module.ecs_repo[5].arn_image
    cart_endpoint        = local.cart_endpoint
    catalogue_url   = local.catalogue_url
    db_host   = local.db_host  
    log_group = "/ecs/${local.shipping_container_name}"
    region = local.region
    container_name = local.shipping_container_name
  }
}

##### microservice payment configurations #####

module "payment" {
  source = "../../modules/roboshop/services"
  depends_on = [module.user, module.cart, module.rabbitmq]
  ##cluster conf
  require_compatibility = var.require_compatibility
  vpc_id = module.ecs_cluster.ecs_vpc_id
  subnet = module.ecs_cluster.ecs_vpc_public_subnet_id
  cluster_arn = module.ecs_cluster.cluster_arn
  namespace = module.ecs_cluster.namespace_arn
  service_sg_name = local.payment_container_name

  ## application conf
  taskdef_service_name = local.payment_container_name
  container_definition = data.template_file.user_json.rendered
  cloudwatch_log_group_name = "/ecs/${local.payment_container_name}"

  ## source conf 
  repo_name = local.repo_name
  branch_name = local.branch_name

  ## build conf
  aws_codebuild_project_name = "code-build-project-payment"
  repo_location = local.repo_location
  build_role_arn = module.ecs_roles.codebuild_role_arn
  # buildspec = data.template_file.cart_buildspec.rendered
    AWS_DEFAULT_REGION = local.region
    IMAGE_REPO_NAME = module.ecs_repo[6].ecr_repository
    AWS_ACCOUNT_ID = local.acc_id
    CONTAINER_NAME = local.payment_container_name
    BUILD_ENV = "dev"
    DIR = "payment"

  ## deployment conf   
  pipeline_role_arn = module.ecs_roles.codepipeline_role_arn
  s3_bucket_name = module.ecs_roles.s3_bucket_name
  code_pipeline_name = "payment-pipeline"
  cluster_name = local.ecs_cluster_name
  service_name = local.payment_container_name
}

data "template_file" "payment_json" {
  template   = file("${path.module}/taskdefinations/payment.json")

  vars = {
    payment_image = module.ecs_repo[6].arn_image
    amqp_host        = local.amqp_host
    cart_host        = local.cart_endpoint
    catalogue_host   = local.catalogue_host
    payment_gateway = local.payment_gateway
    shipping_host   = local.shipping_host
    user_host = local.user_host
    shop_payment_port = local.shop_payment_port  
    log_group = "/ecs/${local.payment_container_name}"
    region = local.region
    container_name = local.payment_container_name
  }
}

##### microservice rating configurations #####

module "rating" {
  source = "../../modules/roboshop/services"
  depends_on = [module.catalogue, module.mysql]
  ##cluster conf
  require_compatibility = var.require_compatibility
  vpc_id = module.ecs_cluster.ecs_vpc_id
  subnet = module.ecs_cluster.ecs_vpc_public_subnet_id
  cluster_arn = module.ecs_cluster.cluster_arn
  namespace = module.ecs_cluster.namespace_arn
  service_sg_name = local.rating_container_name

  ## application conf
  taskdef_service_name = local.rating_container_name
  container_definition = data.template_file.user_json.rendered
  cloudwatch_log_group_name = "/ecs/${local.rating_container_name}"

  ## source conf 
  repo_name = local.repo_name
  branch_name = local.branch_name

  ## build conf
  aws_codebuild_project_name = "code-build-project-rating"
  repo_location = local.repo_location
  build_role_arn = module.ecs_roles.codebuild_role_arn
  # buildspec = data.template_file.cart_buildspec.rendered
    AWS_DEFAULT_REGION = local.region
    IMAGE_REPO_NAME = module.ecs_repo[7].ecr_repository
    AWS_ACCOUNT_ID = local.acc_id
    CONTAINER_NAME = local.rating_container_name
    BUILD_ENV = "dev"
    DIR = "rating"

  ## deployment conf   
  pipeline_role_arn = module.ecs_roles.codepipeline_role_arn
  s3_bucket_name = module.ecs_roles.s3_bucket_name
  code_pipeline_name = "rating-pipeline"
  cluster_name = local.ecs_cluster_name
  service_name = local.rating_container_name
}

data "template_file" "rating_json" {
  template   = file("${path.module}/taskdefinations/rating.json")

  vars = {
    rating_image = module.ecs_repo[7].arn_image
    log_group = "/ecs/${local.rating_container_name}"
    region = local.region
    catalogue_url = local.catalogue_url
    pdo_url = local.pdo_url
    container_name = local.rating_container_name
  }
}

##### microservice dispatch configurations #####

module "dispatch" {
  source = "../../modules/roboshop/services"
  depends_on = [module.rabbitmq]
  ##cluster conf
  require_compatibility = var.require_compatibility
  vpc_id = module.ecs_cluster.ecs_vpc_id
  subnet = module.ecs_cluster.ecs_vpc_public_subnet_id
  cluster_arn = module.ecs_cluster.cluster_arn
  namespace = module.ecs_cluster.namespace_arn
  service_sg_name = local.dispatch_container_name

  ## application conf
  taskdef_service_name = local.dispatch_container_name
  container_definition = data.template_file.user_json.rendered
  cloudwatch_log_group_name = "/ecs/${local.dispatch_container_name}"

  ## source conf 
  repo_name = local.repo_name
  branch_name = local.branch_name

  ## build conf
  aws_codebuild_project_name = "code-build-project-dispatch"
  repo_location = local.repo_location
  build_role_arn = module.ecs_roles.codebuild_role_arn
  # buildspec = data.template_file.cart_buildspec.rendered
    AWS_DEFAULT_REGION = local.region
    IMAGE_REPO_NAME = module.ecs_repo[8].ecr_repository
    AWS_ACCOUNT_ID = local.acc_id
    CONTAINER_NAME = local.dispatch_container_name
    BUILD_ENV = "dev"
    DIR = "dispatch"

  ## deployment conf   
  pipeline_role_arn = module.ecs_roles.codepipeline_role_arn
  s3_bucket_name = module.ecs_roles.s3_bucket_name
  code_pipeline_name = "dispatch-pipeline"
  cluster_name = local.ecs_cluster_name
  service_name = local.shipping_container_name
}

data "template_file" "dispatch_json" {
  template   = file("${path.module}/taskdefinations/dispatch.json")

  vars = {
    dispatch_image = module.ecs_repo[8].arn_image
    amqp_host = local.amqp_host
    log_group = "/ecs/${local.dispatch_container_name}"
    region = local.region
    container_name = local.dispatch_container_name
  }
}


##### microservice web configurations #####

module "web" {
  source = "../../modules/roboshop/web"
  depends_on = [module.user, module.catalogue, module.cart, module.shipping, module.payment, module.rating, module.dispatch]
  ##cluster conf
  require_compatibility = var.require_compatibility
  vpc_id = module.ecs_cluster.ecs_vpc_id
  subnet = module.ecs_cluster.ecs_vpc_public_subnet_id
  cluster_arn = module.ecs_cluster.cluster_arn
  namespace = module.ecs_cluster.namespace_arn
  service_sg_name = local.web_container_name

  ## application conf
  taskdef_service_name = local.web_container_name
  container_definition = data.template_file.web_json.rendered
  cloudwatch_log_group_name = "/ecs/${local.web_container_name}"

  ## source conf 
  repo_name = local.repo_name
  branch_name = local.branch_name

  ## build conf
  aws_codebuild_project_name = "code-build-project-web"
  repo_location = local.repo_location
  build_role_arn = module.ecs_roles.codebuild_role_arn
  # buildspec = data.template_file.cart_buildspec.rendered
    AWS_DEFAULT_REGION = local.region
    IMAGE_REPO_NAME = module.ecs_repo[9].ecr_repository
    AWS_ACCOUNT_ID = local.acc_id
    CONTAINER_NAME = local.web_container_name
    BUILD_ENV = "dev"
    DIR = "web"

  ## deployment conf   
  pipeline_role_arn = module.ecs_roles.codepipeline_role_arn
  s3_bucket_name = module.ecs_roles.s3_bucket_name
  code_pipeline_name = "web-pipeline"
  cluster_name = local.ecs_cluster_name
  service_name = local.web_container_name
}

data "template_file" "web_json" {
  template   = file("${path.module}/taskdefinations/web.json")

  vars = {
    web_image = module.ecs_repo[9].arn_image
    catalogue_host = local.catalogue_host
    cart_host = local.cart_host
    payment_host = local.payment_host
    rating_host = "rating.${var.ecs_namespace}"
    shipping_host = "shipping.${var.ecs_namespace}"
    user_host = "user.${var.ecs_namespace}"
    log_group = "/ecs/${local.web_container_name}"
    region = local.region
    container_name = local.web_container_name
  }
}

module "ecs_repo" {
  source = "../../modules/roboshop/ECRimages"  
  count = length(local.apps) > 0 ? length(local.apps) : 0
  ecr_repo_name = element(local.apps, count.index)
  dockerfile_directory = element(local.apps, count.index)
}

data "aws_secretsmanager_secret_version" "secret-version" {
  secret_id = "arn:aws:secretsmanager:us-east-1:309017165673:secret:mongodb/url-oRPn1y"
}


