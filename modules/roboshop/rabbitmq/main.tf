#### task defination for rabbitmq 4
resource "aws_ecs_task_definition" "rabbitmq" {
  family = var.taskdef_service_name
  container_definitions = data.template_file.rabbitmq_json.rendered
  requires_compatibilities = var.require_compatibility
  execution_role_arn = "arn:aws:iam::309017165673:role/ecsTaskExecutionRole"
  task_role_arn = "arn:aws:iam::309017165673:role/ecsTaskExecutionRole"
  memory = 1024
  network_mode = "awsvpc"
}

data "template_file" "rabbitmq_json" {
  template   = file("${path.module}/rabbitmq.json")
  vars = {
    rabbitmq_image = var.rabbitmq_image_uri
  }
}


# ### Service Discovery and Service For RabbitMQ 4

resource "aws_service_discovery_service" "rabbitmq_service" {
  name = var.taskdef_service_name

  dns_config {
    namespace_id = var.namespace

    dns_records {
      ttl  = 10
      type = "A"
    }
  }
}

resource "aws_ecs_service" "rabbitmq" {
  name            = var.taskdef_service_name
  cluster         =  var.cluster_arn
  task_definition = aws_ecs_task_definition.rabbitmq.arn
  desired_count   = 1
  launch_type = "EC2"
  ordered_placement_strategy {
    type  = "binpack"
    field = "cpu"
  }
  network_configuration {
    subnets          = var.subnet
    assign_public_ip = false
    security_groups = [aws_security_group.rabbitmq-sg.id]
  }
  service_registries {
    registry_arn = aws_service_discovery_service.rabbitmq_service.arn
  }
}

resource "aws_security_group" "rabbitmq-sg" {
  name        = "allow_tls_rabbitmq"
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