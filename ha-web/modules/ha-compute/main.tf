# Launch Template for application instances
resource "aws_launch_template" "ha_app" {
  name_prefix           = "${var.name_prefix}-app-"
  image_id              = var.ami_id
  instance_type         = var.instance_type
  vpc_security_group_ids = [var.app_security_group_id]

  iam_instance_profile {
    name = var.instance_profile_name
  }

  user_data = base64encode(<<-EOF
    #!/bin/bash
    yum update -y
    yum install -y docker
    systemctl start docker
    systemctl enable docker
    usermod -a -G docker ec2-user

    # Login to ECR and pull the image
    aws ecr get-login-password --region ${var.aws_region} | docker login --username AWS --password-stdin ${var.ecr_account_id}.dkr.ecr.${var.aws_region}.amazonaws.com
    docker pull ${var.ecr_account_id}.dkr.ecr.${var.aws_region}.amazonaws.com/${var.ecr_repo_name}:${var.ecr_image_tag}

    # Run the container
    docker run -d --name ha-web-app \
      -p 3000:3000 \
      -e PORT=3000 \
      -e HOST=0.0.0.0 \
      ${var.ecr_account_id}.dkr.ecr.${var.aws_region}.amazonaws.com/${var.ecr_repo_name}:${var.ecr_image_tag}
  EOF
  )

  tag_specifications {
    resource_type = "instance"
    tags = merge(var.common_tags, {
      Name = "${var.name_prefix}-app"
    })
  }

  tags = merge(var.common_tags, {
    Name = "${var.name_prefix}-lt"
  })
}

# Auto Scaling Group
resource "aws_autoscaling_group" "ha_app" {
  name                = "${var.name_prefix}-asg"
  desired_capacity    = var.desired_capacity
  min_size            = var.min_size
  max_size            = var.max_size
  vpc_zone_identifier = var.private_subnet_ids

  launch_template {
    id      = aws_launch_template.ha_app.id
    version = "$Latest"
  }

  tag {
    key                 = "Name"
    value               = "${var.name_prefix}-app"
    propagate_at_launch = true
  }

  dynamic "tag" {
    for_each = var.common_tags
    content {
      key                 = tag.key
      value               = tag.value
      propagate_at_launch = true
    }
  }

  # Target group attachment
  target_group_arns = [var.target_group_arn]

  # Health check grace period
  health_check_grace_period = 300
  health_check_type         = "ELB"
}

# CPU Target Tracking Scaling Policy
resource "aws_autoscaling_policy" "cpu_scaling" {
  name                   = "${var.name_prefix}-cpu-scaling"
  autoscaling_group_name = aws_autoscaling_group.ha_app.name
  policy_type            = "TargetTrackingScaling"

  target_tracking_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ASGAverageCPUUtilization"
    }
    target_value       = 50.0
    disable_scale_in   = false
  }
}