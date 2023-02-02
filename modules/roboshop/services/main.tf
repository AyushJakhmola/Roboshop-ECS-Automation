#### task defination 

resource "aws_ecs_task_definition" "service_defination" {
  family = var.taskdef_service_name
  container_definitions = var.container_definition
  requires_compatibilities = var.require_compatibility
  execution_role_arn = "arn:aws:iam::309017165673:role/ecsTaskExecutionRole"
  task_role_arn = "arn:aws:iam::309017165673:role/ecsTaskExecutionRole"
  memory = 1024
  network_mode = "awsvpc"
}

# ### Service Discovery and Service 

resource "aws_service_discovery_service" "service_discovery" {
  name = var.taskdef_service_name

  dns_config {
    namespace_id = var.namespace

    dns_records {
      ttl  = 10
      type = "A"
    }
  }
}

resource "aws_ecs_service" "service" {
  name            = var.taskdef_service_name
  cluster         = var.cluster_arn
  task_definition = aws_ecs_task_definition.service_defination.arn
  desired_count   = 1
  launch_type = var.service_launch_type
  ordered_placement_strategy {
    type  = "binpack"
    field = "cpu"
  }
  network_configuration {
    subnets          = var.subnet
    assign_public_ip = false
    security_groups = [aws_security_group.service_sg.id]
  }
  service_registries {
    registry_arn = aws_service_discovery_service.service_discovery.arn
  }
  #   load_balancer {
  #   count = 0
  #   target_group_arn = "module.web-alb.target_group_arns[0]"
  #   container_name   = "web"
  #   container_port   = 8080
  # }
}

resource "aws_security_group" "service_sg" {
  name        = var.service_sg_name
  description = "Allow TLS inbound traffic"
  vpc_id      = var.vpc_id

  ingress {
    description = "TLS from VPC"
    from_port   = 0
    to_port     = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
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

resource "aws_cloudwatch_log_group" "task_logs" {
  name = var.cloudwatch_log_group_name
}