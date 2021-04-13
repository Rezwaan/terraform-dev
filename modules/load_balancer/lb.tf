resource "aws_alb" "nginx_alb" {
  name               = "nginx-lb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.webapp_http_inbound_sg.id]
  subnets = [aws_subnet.public[0].id,aws_subnet.public[1].id,aws_subnet.public[2].id]

  tags = {
    Environment = "dev-nginx"
  }
}

resource "aws_lb_target_group" "nginx-lbtg" {
  name     = "nginx-target-group"
  port     = "80"
  protocol = "HTTP"
  vpc_id   = "${aws_vpc.homelike-vpc.id}"
  deregistration_delay = "300"
  health_check {
    interval = "30"
    port = "80" 
  }
}

resource "aws_lb_listener" "front_end-nginx" {
  load_balancer_arn = "${aws_alb.nginx_alb.arn}"
  port              = "80"
  protocol          = "HTTP"
  default_action {
    target_group_arn = "${aws_lb_target_group.nginx-lbtg.arn}"
    type             = "forward"
  }
}
