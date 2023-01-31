locals {
  user_data = <<EOF
  #!/bin/bash
  echo ECS_CLUSTER=ecs-robotshop-ec2 >> /etc/ecs/ecs.config;echo ECS_BACKEND_HOST= >> /etc/ecs/ecs.config;
  EOF
}


#### security group for cluster instances ####
resource "aws_security_group" "ec2-ecs-sg" {
  name        = "allow_tls_ec2-ecs-sg"
  description = "Allow TLS inbound traffic"
  vpc_id      = module.vpc.vpc_id

  ingress {
    description = "TLS from VPC"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks      = ["${var.vpc_cidr}"]
  }
  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    Name =  "allow_tls"
  }
}

module "asg" {
  source = "terraform-aws-modules/autoscaling/aws"
   for_each = {
    one = {
      instance_type = "t3a.medium"
    }
   } 
  # Autoscaling group
  name = "ec2-ecs-asg"

  min_size                  = var.min_size
  max_size                  = var.max_size
  desired_capacity          = var.desired_capacity
  wait_for_capacity_timeout = 0
  health_check_type         = "EC2"
  vpc_zone_identifier       = module.vpc.public_subnets
  
  # Launch template
  launch_template_name        = "ec2-ecs-asg-temp"
  launch_template_description = "Launch template for ec2 ecs"
  update_default_version      = true

  image_id                    = var.cluster_instance_image_id
  instance_type               = var.cluster_instance_type
  key_name                    = var.instance_key_name
  user_data         = base64encode(local.user_data)
  create_iam_instance_profile = true
  iam_role_name               = "ecs-role-ec2"
  iam_role_description        = "ECS role for ecs-role-ec2"
  iam_role_policies = {
    AmazonEC2ContainerServiceforEC2Role = "arn:aws:iam::aws:policy/service-role/AmazonEC2ContainerServiceforEC2Role"
    # AmazonSSMManagedInstanceCore        = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
  }

  block_device_mappings = [
    {
      # Root volume
      device_name = "/dev/xvda"
      no_device   = 0
      ebs = {
        delete_on_termination = true
        encrypted             = true
        volume_size           = var.instance_volume_size
        volume_type           = var.instance_volume_type
      }
      }
  ]
  network_interfaces = [
    {
      delete_on_termination = true
      description           = "eth0"
      device_index          = 0
      security_groups       = [aws_security_group.ec2-ecs-sg.id]
    }
  ]

  tags = {
    Environment = "stg"
  }
}

module "ecs" {
  source = "terraform-aws-modules/ecs/aws"

  cluster_name = var.cluster_name
  cluster_settings = {
  "name": "containerInsights",
  "value": "disabled"
}
  cluster_configuration = {
    execute_command_configuration = {
      logging = "OVERRIDE"
      log_configuration = {
        cloud_watch_log_group_name = "/aws/ecs/aws-ec2"
      }
    }
  }
  # Capacity provider - autoscaling groups
  autoscaling_capacity_providers = {
    one = {
      auto_scaling_group_arn         = module.asg["one"].autoscaling_group_arn
      # managed_termination_protection = "ENABLED"

      managed_scaling = {
        maximum_scaling_step_size = 5
        minimum_scaling_step_size = 1
        status                    = "ENABLED"
        target_capacity           = 60
      }

      default_capacity_provider_strategy = {
        weight = 60
        base   = 20
      }
    }
  }

  tags = {
    Environment = "stg"
    Project     = "EcsEc2"
  }
}

### NameSpace in Route 53
resource "aws_service_discovery_private_dns_namespace" "robotshop_namespace" {
  name        = var.ecs_namespace
  description = "name space"
  vpc         = module.vpc.vpc_id
}