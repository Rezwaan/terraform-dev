variable lc-name-prefix {
  type    = string
  default = "asg-name"
}

variable image_id {
  type    = string
  default = "ubuntu"
}

variable instance_type {
  type    = string
  default = "t2.micro"
}


variable security_groups {
  type    = list
  default = ["module.webapp_http_inbound_sg.security_group_id","module.webapp_ssh_inbound_sg.security_group_id"]
}

variable lc-associate_public_ip_address-prefix {
  type    = string
  default = "true"
}

variable key_name {
  type    = string
  default = "homelike-key"
}

variable subnet_id {
  type    = list
  default = ["subnet_id"]
}


variable asg_name {
  type    = string
  default = "homelike-asg"
}

variable maximum_instances {
  type    = number
  default = 3
}

variable minimum_instances {
  type    = number
  default = 2
}

variable load_balancers {
  type    = list
  default = ["aws_elb.webapp_elb.name"]
}

variable target_group_arns {
  type    = list
  default = ["aws_elb.webapp_elb.name"]
}

variable iam_instance_profile {
  type    = string
  default = "instance_profile"
}

variable associate_public_ip_address {
  type    = bool
  default = true
}

variable data {
  type    = string
  default = "data"
}

variable is_classic_load_balancer {
  type    = bool
  default = false
}

variable tag_name {
  type    = string
  default = "data"
}