resource "aws_elb" "webapp_elb" {
  #name    = "homelike-webapp-elb"
  name    = var.elb_name
  #subnets =  [aws_subnet.public[0].id,aws_subnet.public[1].id,aws_subnet.public[2].id]
  subnets =  var.subnets

  listener {
    #instance_port     = 80
    instance_port     = var.instance_port
    #instance_protocol = "http"
    instance_protocol = var.instance_protocol
    #lb_port           = 80
    lb_port           = var.load_balancer_port
    #lb_protocol       = "http"
    lb_protocol       = var.load_balancer_protocol
  }

  health_check {
    healthy_threshold   = 2
    unhealthy_threshold = 2
    timeout             = 3
    #target              = "HTTP:80/"
    target              = var.health_check_target
    interval            = 10
  }

  #security_groups = [aws_security_group.webapp_http_inbound_sg.id]
  security_groups = var.security_groups

  tags = {
    Environment = "dev-app"
  }

}