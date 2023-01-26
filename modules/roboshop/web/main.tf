#### task defination for web 12

data "template_file" "web_temp" {
  template   = file("${path.module}/web.json")

  vars = {
  cart_host = var.cart_host
  catalogue_host = var.catalogue_host
  payment_host = var.payment_host
  rating_host = var.rating_host
  shipping_host = var.shipping_host
  user_host = var.user_host
  }
}

resource "aws_ecs_task_definition" "web" {
  family = var.taskdef_service_name
  container_definitions = data.template_file.web_temp.rendered
  requires_compatibilities = var.require_compatibility
  execution_role_arn = "arn:aws:iam::309017165673:role/ecsTaskExecutionRole"
  task_role_arn = "arn:aws:iam::309017165673:role/ecsTaskExecutionRole"
  memory = 1024
  network_mode = "awsvpc"
}

# ### Service Discovery and Service For web 12

resource "aws_service_discovery_service" "web_service" {
  name = var.taskdef_service_name

  dns_config {
    namespace_id = var.namespace

    dns_records {
      ttl  = 10
      type = "A"
    }
  }
}

resource "aws_ecs_service" "web" {
  name            = var.taskdef_service_name
  cluster         =  var.cluster_arn
  task_definition = aws_ecs_task_definition.web.arn
  desired_count   = 1
  launch_type = "EC2"
  ordered_placement_strategy {
    type  = "binpack"
    field = "cpu"
  }
  network_configuration {
    subnets          = var.subnet
    assign_public_ip = false  
    security_groups = [aws_security_group.web-sg.id] 
  }
  service_registries {
    registry_arn = aws_service_discovery_service.web_service.arn
  }
  load_balancer {
    target_group_arn = module.web-alb.target_group_arns[0]
    container_name   = "web"
    container_port   = 8080
  }

}

resource "aws_security_group" "web-sg" {
  name        = "allow_tls_web"
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