output "vpc_id" {
  description = "ID of the VPC"
  value       = module.ha_vpc.vpc_id
}

output "public_subnet_ids" {
  description = "List of public subnet IDs"
  value       = module.ha_vpc.public_subnet_ids
}

output "private_subnet_ids" {
  description = "List of private subnet IDs"
  value       = module.ha_vpc.private_subnet_ids
}

output "alb_dns_name" {
  description = "DNS name of the Application Load Balancer"
  value       = module.ha_alb.alb_dns_name
}

output "alb_arn" {
  description = "ARN of the Application Load Balancer"
  value       = module.ha_alb.alb_arn
}

output "target_group_arn" {
  description = "ARN of the target group"
  value       = module.ha_alb.target_group_arn
}

output "autoscaling_group_name" {
  description = "Name of the Auto Scaling Group"
  value       = module.ha_compute.autoscaling_group_name
}

output "ec2_instance_profile_name" {
  description = "Name of the EC2 instance profile"
  value       = module.ha_iam.instance_profile_name
}