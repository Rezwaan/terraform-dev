resource "aws_elb" "webapp_elb" {
  name    = "homelike-webapp-elb"
  subnets = module.public-subnet.subnet_id
  #subnets = [aws_subnet.public[0].id,aws_subnet.public[1].id,aws_subnet.public[2].id]

  listener {
    instance_port     = 80
    instance_protocol = "http"
    lb_port           = 80
    lb_protocol       = "http"
  }

  health_check {
    healthy_threshold   = 2
    unhealthy_threshold = 2
    timeout             = 3
    target              = "HTTP:80/"
    interval            = 10
  }

  security_groups = [module.webapp_http_inbound_sg.security_group_id]
  
  tags = {
    Environment = "dev-app"
  }

}

#### Application Load Balancer for NGINX Servers
resource "aws_alb" "nginx_alb" {
  name               = "nginx-lb"
  internal           = false
  load_balancer_type = "application"
  security_groups = [module.webapp_http_inbound_sg.security_group_id]
  subnets = module.public-subnet.subnet_id
  
  tags = {
    Environment = "dev-nginx"
  }
}

resource "aws_lb_target_group" "nginx-lbtg" {
  name     = "nginx-target-group"
  port     = "80"
  protocol = "HTTP"
  vpc_id   = module.homelike-vpc.vpc_id
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
