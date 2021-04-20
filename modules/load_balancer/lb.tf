resource "aws_alb" "nginx_alb" {
  #name               = "nginx-lb"
  name               = var.alb_name
  internal           = false
  #load_balancer_type = "application"
  load_balancer_type = var.lb_type
  #security_groups    = [aws_security_group.webapp_http_inbound_sg.id]
  security_groups    = var.security_groups
  #subnets = [aws_subnet.public[0].id,aws_subnet.public[1].id,aws_subnet.public[2].id]
  subnets = var.subnets

  tags = {
    Environment = "dev-nginx"
  }
}

resource "aws_lb_target_group" "nginx-lbtg" {
  #name     = "nginx-target-group"
  name     = var.target_group_name
  #port     = "80"
  port     = var.target_group_port
  #protocol = "HTTP"
  protocol = var.target_group_protocol
  #vpc_id   = "${aws_vpc.homelike-vpc.id}"
  vpc_id   = var.vpc_id
  deregistration_delay = "300"
  health_check {
    interval = "30"
    port = "80" 
  }
}

resource "aws_lb_listener" "front_end-nginx" {
  load_balancer_arn = "${aws_alb.nginx_alb.arn}"
  #port              = "80"
  port              = var.listener_port
  #protocol          = "HTTP"
  protocol          = var.listener_protocol
  default_action {
    target_group_arn = "${aws_lb_target_group.nginx-lbtg.arn}"
    type             = "forward"
  }
}
