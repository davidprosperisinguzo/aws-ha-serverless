output "launch_template_id" {
  description = "ID of the launch template"
  value       = aws_launch_template.ha_app.id
}

output "launch_template_name" {
  description = "Name of the launch template"
  value       = aws_launch_template.ha_app.name
}

output "autoscaling_group_name" {
  description = "Name of the Auto Scaling Group"
  value       = aws_autoscaling_group.ha_app.name
}

output "autoscaling_group_arn" {
  description = "ARN of the Auto Scaling Group"
  value       = aws_autoscaling_group.ha_app.arn
}