
variable elb_name {
  type    = string
  default = "homelike-elb"
}

variable subnets {
  type    = list
  default = ["homelike-elb"]
}

variable instance_protocol {
  type    = string
  default = "http"
}

variable instance_port {
  type    = number
  default = 80
}

variable load_balancer_port {
  type    = number
  default = 80
}

variable load_balancer_protocol {
  type    = string
  default = "http"
}


variable health_check_target {
  type    = string
  default = "HTTP:80/"
}


variable security_groups {
  type    = list
  default = ["module.webapp_http_inbound_sg.security_group_id","module.webapp_ssh_inbound_sg.security_group_id"]
}