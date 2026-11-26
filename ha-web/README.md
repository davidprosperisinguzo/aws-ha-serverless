# HA Web Stack

Highly available web application infrastructure using Terraform on AWS.

## Architecture

- **VPC** with public and private subnets across 2 Availability Zones
- **Internet Gateway** for public subnet internet access
- **NAT Gateways** (one per AZ) for private subnet outbound internet access
- **Application Load Balancer** in public subnets
- **Auto Scaling Group** in private subnets (min 2, max 4 instances)
- **Launch Template** with user data to run Node.js container from ECR
- **IAM Role** with SSM and ECR permissions

## Modules

| Module | Description |
|--------|-------------|
| `ha-vpc` | VPC, subnets, IGW, NAT Gateways, route tables |
| `ha-security` | Security groups for ALB and application instances |
| `ha-alb` | Application Load Balancer, target group, HTTP listener |
| `ha-iam` | EC2 IAM role, policies, instance profile |
| `ha-compute` | Launch Template, Auto Scaling Group, CPU scaling policy |

## Requirements

- Terraform >= 1.16.0
- AWS Provider ~> 5.0
- ECR repository `nodejs-cicd-app` with image tag `latest`
- AWS Account ID for ECR access

## Usage

```bash
cd ha-web
cp terraform.tfvars.example terraform.tfvars
# Edit terraform.tfvars with your values
terraform init
terraform fmt -recursive
terraform validate
terraform plan
terraform apply
```

## Variables

| Variable | Description | Default |
|----------|-------------|---------|
| `project_name` | Project name | `aws-ha-serverless` |
| `stack_name` | Stack name | `ha` |
| `environment` | Environment | `dev` |
| `aws_region` | AWS region | `eu-west-2` |
| `vpc_cidr` | VPC CIDR | `10.0.0.0/16` |
| `availability_zones` | AZs (exactly 2) | `["eu-west-2a", "eu-west-2b"]` |
| `ami_id` | AMI ID (Amazon Linux 2023) | `ami-0a3c3a20c09d6f377` |
| `instance_type` | EC2 instance type | `t3.micro` |
| `desired_capacity` | ASG desired capacity | `2` |
| `min_size` | ASG minimum size | `2` |
| `max_size` | ASG maximum size | `4` |
| `ecr_account_id` | AWS Account ID for ECR | *required* |
| `ecr_repo_name` | ECR repository name | `nodejs-cicd-app` |
| `ecr_image_tag` | ECR image tag | `latest` |

## Outputs

- `vpc_id` - VPC ID
- `public_subnet_ids` - Public subnet IDs
- `private_subnet_ids` - Private subnet IDs
- `alb_dns_name` - ALB DNS name
- `alb_arn` - ALB ARN
- `target_group_arn` - Target group ARN
- `autoscaling_group_name` - ASG name
- `ec2_instance_profile_name` - EC2 instance profile name

## Application

The application runs on port 3000 and displays:
- "Hello World"
- Container hostname (for load distribution verification)

## Security

- Application instances in private subnets only
- ALB security group allows HTTP/HTTPS from internet
- Application security group allows port 3000 only from ALB
- No SSH access - use AWS Systems Manager Session Manager
- IAM least-privilege policies

## Cost Considerations

- 2 NAT Gateways (one per AZ) - ~$0.045/hour each
- 1 Application Load Balancer - ~$0.0225/hour
- EC2 instances (t3.micro) - ~$0.0104/hour each
- Remember to destroy resources after testing