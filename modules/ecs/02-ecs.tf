locals {
  user_data = <<EOF
  #!/bin/bash
  echo ECS_CLUSTER=ecs-robotshop-ec2 >> /etc/ecs/ecs.config;echo ECS_BACKEND_HOST= >> /etc/ecs/ecs.config;
  EOF
}

resource "aws_security_group" "ec2-ecs-sg" {
  name        = "allow_tls_ec2-ecs-sg"
  description = "Allow TLS inbound traffic"
  vpc_id      = var.vpc_id

  ingress {
    description = "TLS from VPC"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
  }
  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    Name = "allow_tls"
  }
}

module "asg" {
  source = "terraform-aws-modules/autoscaling/aws"

  # Autoscaling group
  name = "ec2-ecs-asg"

  min_size                  = 0
  max_size                  = 7
  desired_capacity          = 7
  wait_for_capacity_timeout = 0
  health_check_type         = "EC2"
  vpc_zone_identifier       = var.subnet
  
  # Launch template
  launch_template_name        = "ec2-ecs-asg-temp"
  launch_template_description = "Launch template for ec2 ecs"
  update_default_version      = true

  image_id                    = "ami-014cdb1bfb3b2584f"
  instance_type               = "t3a.medium"
  key_name                    = "ayush-squareops"
  user_data         = base64encode(local.user_data)
  create_iam_instance_profile = true
  iam_role_name               = "ecs-role-ec2"
  iam_role_description        = "ECS role for ecs-role-ec2"
  iam_role_policies = {
    AmazonEC2ContainerServiceforEC2Role = "arn:aws:iam::aws:policy/service-role/AmazonEC2ContainerServiceforEC2Role"
    AmazonSSMManagedInstanceCore        = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
  }

  block_device_mappings = [
    {
      # Root volume
      device_name = "/dev/xvda"
      no_device   = 0
      ebs = {
        delete_on_termination = true
        encrypted             = true
        volume_size           = 30
        volume_type           = "gp2"
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

  cluster_name = "ecs-robotshop-ec2"
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

  tags = {
    Environment = "stg"
    Project     = "EcsEc2"
  }
}

### NameSpace in Route 53
resource "aws_service_discovery_private_dns_namespace" "robotshop_namespace" {
  name        = "robotshoptf"
  description = "name space"
  vpc         = var.vpc_id
}