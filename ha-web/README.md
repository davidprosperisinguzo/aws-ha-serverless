# ha-web Stack

A multi-AZ, highly available web application with an Application Load Balancer, Auto Scaling Group, and NAT gateways. The app runs a Node.js container from ECR.

## Deploy

```bash
terraform init
terraform plan
terraform apply
```

## Destroy

```bash
terraform destroy
```