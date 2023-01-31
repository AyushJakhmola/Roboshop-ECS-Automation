module "vpc" {
  source = "terraform-aws-modules/vpc/aws"

  name = var.vpc_name
  cidr = var.vpc_cidr

  azs             = var.vpc_az
  private_subnets = var.private_subnets_cidr
  public_subnets  = var.public_subnets_cidr
  enable_nat_gateway = true
  single_nat_gateway = true

  tags = {
    Terraform   = "true"
    Environment = "stg"
  }
}