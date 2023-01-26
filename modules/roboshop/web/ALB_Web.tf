# security group for web alb 
resource "aws_security_group" "web-alb-sg" {
  name        = "allow_tls_alb_web"
  description = "Allow TLS inbound traffic"
  vpc_id      = var.vpc_id

  ingress {
    description = "TLS from VPC"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    description = "TLS from VPC"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
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

# ######## alb for web

module "web-alb" {
  source  = "terraform-aws-modules/alb/aws"
  version = "~> 8.0"

  name = "web-alb"

  load_balancer_type = "application"

  vpc_id          = var.vpc_id
  subnets         = var.subnet
  security_groups = [aws_security_group.web-alb-sg.id]

  target_groups = [
    {
      name_prefix      = "web"
      backend_protocol = "HTTP"
      backend_port     = 8080
      target_type      = "ip"

      health_check = {
        enabled             = true
        interval            = 30
        path                = "/"
        port                = "traffic-port"
        healthy_threshold   = 3
        unhealthy_threshold = 3
        timeout             = 6
        protocol            = "HTTP"
        matcher             = "200"
      }
    }
  ]

  # https_listeners = [
  #   {
  #     port               = 443
  #     protocol           = "HTTPS"
  #     certificate_arn    = "arn:aws:acm:us-west-2:421320058418:certificate/73b9c44b-3865-4f0a-b508-dc118857ae2e"
  #     target_group_index = 0
  #   }
  # ]

  http_tcp_listeners = [
    {
      port               = 80
      protocol           = "HTTP"
      target_group_index = 0
    }
  ]

  tags = {
    Environment = "stg"
  }
}