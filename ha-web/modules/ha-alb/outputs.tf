output "alb_arn" {
  description = "ARN of the Application Load Balancer"
  value       = aws_lb.ha_alb.arn
}

output "alb_dns_name" {
  description = "DNS name of the Application Load Balancer"
  value       = aws_lb.ha_alb.dns_name
}

output "alb_zone_id" {
  description = "Zone ID of the Application Load Balancer"
  value       = aws_lb.ha_alb.zone_id
}

output "target_group_arn" {
  description = "ARN of the target group"
  value       = aws_lb_target_group.app_tg.arn
}

output "target_group_name" {
  description = "Name of the target group"
  value       = aws_lb_target_group.app_tg.name
}