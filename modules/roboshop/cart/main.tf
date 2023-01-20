#### task defination for cart 7

data "template_file" "cart_temp" {
  template   = file("${path.module}/cart.json")

  vars = {
    catalogue_host   = "catalogue.robotshoptf"
    redis_host = "redis.robotshoptf"
    cart_server_port = 8080
  }
}
resource "aws_ecs_task_definition" "cart" {
  family = "carttf"
  container_definitions = data.template_file.cart_temp.rendered
  requires_compatibilities = var.require_compatibility
  execution_role_arn = "arn:aws:iam::421320058418:role/ecsTaskExecutionRole"
  task_role_arn = "arn:aws:iam::421320058418:role/ecsTaskExecutionRole"
  memory = 1024
  network_mode = "awsvpc"
}

# ### Service Discovery and Service For cart 7 

resource "aws_service_discovery_service" "cart_service" {
  name = "cart"

  dns_config {
    namespace_id = var.namespace

    dns_records {
      ttl  = 10
      type = "A"
    }
  }
}

resource "aws_ecs_service" "cart" {
  name            = "cart"
  cluster         = var.cluster_arn
  task_definition = aws_ecs_task_definition.cart.arn
  desired_count   = 1
  launch_type = "EC2"
  ordered_placement_strategy {
    type  = "binpack"
    field = "cpu"
  }
  network_configuration {
    subnets          = var.subnet
    assign_public_ip = false
    security_groups = [aws_security_group.cart-sg.id]
  }
  service_registries {
    registry_arn = aws_service_discovery_service.cart_service.arn
  }
}

resource "aws_security_group" "cart-sg" {
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