output "lb_target_group_arn" {
  value = aws_lb_target_group.dev-tg.arn
}
output "lb_id" {
  value = aws_lb.dev-loadbalancer.id
}
