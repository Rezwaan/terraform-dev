
resource "aws_launch_configuration" "launch_conf" {
  lifecycle {
    create_before_destroy = true
  }

  name_prefix   = var.lc-name-prefix
  image_id      = var.image_id
  instance_type = var.instance_type

  #security_groups = [
  #  module.webapp_http_inbound_sg.security_group_id,
  #  module.webapp_ssh_inbound_sg.security_group_id,
  #]

  security_groups = var.security_groups


  #user_data                    = data.template_file.node-userdata.rendered
  user_data                    = var.data
  associate_public_ip_address  = var.associate_public_ip_address
  #iam_instance_profile        = aws_iam_instance_profile.asg.name
  iam_instance_profile         = var.iam_instance_profile
  #key_name                    = aws_key_pair.homelike-key-pair.key_name
  key_name                     = var.key_name                                 
}

## ASG with Classic Load Balancer
resource "aws_autoscaling_group" "classic_asg" {
  lifecycle {
    create_before_destroy = false
  }
  
  count = var.is_classic_load_balancer ? 1 : 0

  #vpc_zone_identifier  = module.public-subnet.subnet_id
  vpc_zone_identifier   = var.subnet_id                                           
  name                  = var.asg_name                                           
  max_size              = var.maximum_instances
  min_size              = var.minimum_instances
  force_delete          = true
  launch_configuration  = aws_launch_configuration.launch_conf.id
  load_balancers        = var.load_balancers
  
  tag {
    key                 = "Name"
    value               = var.tag_name
    propagate_at_launch = true
  }
}

## ASG with Application Load Balancer
resource "aws_autoscaling_group" "application_asg" {
  lifecycle {
    create_before_destroy = false
  }
  
  count = var.is_classic_load_balancer ? 0 : 1

  #vpc_zone_identifier  = module.public-subnet.subnet_id
  vpc_zone_identifier   = var.subnet_id                                           
  name                  = var.asg_name                                           
  max_size              = var.maximum_instances
  min_size              = var.minimum_instances
  force_delete          = true
  launch_configuration  = aws_launch_configuration.launch_conf.id
  target_group_arns     = var.target_group_arns

  tag {
    key                 = "Name"
    value               = var.tag_name
    propagate_at_launch = true
  }
}
