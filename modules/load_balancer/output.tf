output "alb_name" {
  value = aws_alb.nginx_alb.name
}

output "target_group_arn" {
  value = aws_lb_target_group.nginx-lbtg.arn
}