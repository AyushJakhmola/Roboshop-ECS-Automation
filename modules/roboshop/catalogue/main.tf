#### task defination for catalogue 5

data "template_file" "catalogue_temp" {
  template   = file("${path.module}/catalogue.json")

  vars = {
    container_port        = 8080
    mongodb_url        = "mongodb://robo:asdfghjkl123@mongo.db.robotshoptf/admin"
  }
}

resource "aws_ecs_task_definition" "catalogue" {
  family = "cataloguetf"
  container_definitions = data.template_file.catalogue_temp.rendered
  requires_compatibilities = var.require_compatibility
  execution_role_arn = "arn:aws:iam::421320058418:role/ecsTaskExecutionRole"
  task_role_arn = "arn:aws:iam::421320058418:role/ecsTaskExecutionRole"
  memory = 1024
  network_mode = "awsvpc"
}

# ### Service Discovery and Service For Catalogue 5

resource "aws_service_discovery_service" "catalogue_service" {
  name = "catalogue"

  dns_config {
    namespace_id = var.namespace

    dns_records {
      ttl  = 10
      type = "A"
    }
  }
}

resource "aws_ecs_service" "catalogue" {
  name            = "catalogue"
  cluster         =  var.cluster_arn
  task_definition = aws_ecs_task_definition.catalogue.arn
  desired_count   = 1
  launch_type = "EC2"
  ordered_placement_strategy {
    type  = "binpack"
    field = "cpu"
  }
  network_configuration {
    subnets          = var.subnet
    assign_public_ip = false
    security_groups = [aws_security_group.catalogue-sg.id]
  }
  service_registries {
    registry_arn = aws_service_discovery_service.catalogue_service.arn
  }
}

resource "aws_security_group" "catalogue-sg" {
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