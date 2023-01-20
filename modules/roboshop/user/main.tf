#### task defination for user 5

data "template_file" "user_temp" {
  template   = file("${path.module}/user.json")

  vars = {
    redis_url        = "redis.robotshoptf"
    mongodb_url        = "mongodb://robo:asdfghjkl123@mongo.db.robotshoptf/admin"
    user_server_port = "8080"
  }
}

resource "aws_ecs_task_definition" "user" {
  family = "usertf"
  container_definitions = data.template_file.user_temp.rendered
  requires_compatibilities = var.require_compatibility
  execution_role_arn = "arn:aws:iam::421320058418:role/ecsTaskExecutionRole"
  task_role_arn = "arn:aws:iam::421320058418:role/ecsTaskExecutionRole"
  memory = 1024
  network_mode = "awsvpc"
}


# ### Service Discovery and Service For user 6

resource "aws_service_discovery_service" "user_service" {
  name = "user"

  dns_config {
    namespace_id = var.namespace

    dns_records {
      ttl  = 10
      type = "A"
    }
  }
}

resource "aws_ecs_service" "user" {
  name            = "user"
  cluster         = var.cluster_arn
  task_definition = aws_ecs_task_definition.user.arn
  desired_count   = 1
  launch_type = "EC2"
  ordered_placement_strategy {
    type  = "binpack"
    field = "cpu"
  }
  network_configuration {
    subnets          = var.subnet
    assign_public_ip = false
    security_groups = [aws_security_group.user-sg.id]
  }
  service_registries {
    registry_arn = aws_service_discovery_service.user_service.arn
  }
}

resource "aws_security_group" "user-sg" {
  name        = "allow_tls_catalogue"
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