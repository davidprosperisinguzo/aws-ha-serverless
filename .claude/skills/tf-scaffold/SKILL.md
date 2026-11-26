---
name: tf-scaffold
description: Designs, scaffolds, and writes maintainable Terraform configurations for the aws-ha-serverless project using a mandatory module-first architecture, consistent naming conventions, explicit AWS Name tags, and Terraform best practices. Use when creating or modifying Terraform stacks, resources, or reusable modules.
---

# TF Scaffold

## Mission

Create and maintain the Terraform configurations for the `aws-ha-serverless` assignment.

The responsibility of this skill is to write complete, modular, maintainable, and production-minded Terraform configurations for the project's two infrastructure stacks:

- `ha-web/`
- `serverless/`

All Terraform configurations must follow a module-first architecture. Every managed AWS resource must be declared inside a Terraform module. Modules must be properly connected through inputs and outputs, and resource naming and tagging must remain consistent throughout the project.

This skill is responsible for writing Terraform configurations, not deploying infrastructure.

The user alone executes commands, reviews plans, approves infrastructure changes, applies or destroys resources, runs tests, and captures screenshots.

---

## 1. Read Project Instructions Before Starting

Before creating or modifying any Terraform configuration, inspect:

1. The root `CLAUDE.md`.
2. The assignment requirements.
3. Existing project structure and README files.
4. Existing Terraform configurations and module interfaces.
5. Relevant architecture review findings.
6. Relevant security review findings.

Treat the project's `CLAUDE.md` and assignment requirements as authoritative.

Do not introduce infrastructure that is outside the assignment scope.

Do not overwrite existing user work without understanding its purpose.

If a requirement is ambiguous and could affect architecture, cost, security, or infrastructure behavior, explain the ambiguity and ask the user before proceeding.

## 2. Mandatory Module-First Architecture

**Every managed AWS resource must be declared inside a Terraform module.**

This is a mandatory project requirement.

Never declare managed AWS resources directly inside the root stack configuration.

Examples of resources that must be inside modules include:

- `aws_vpc`
- `aws_subnet`
- `aws_internet_gateway`
- `aws_nat_gateway`
- `aws_route_table`
- `aws_security_group`
- `aws_lb`
- `aws_lb_listener`
- `aws_lb_target_group`
- `aws_launch_template`
- `aws_autoscaling_group`
- `aws_iam_role`
- `aws_iam_policy`
- `aws_instance`
- `aws_s3_bucket`
- `aws_dynamodb_table`
- `aws_lambda_function`
- `aws_apigatewayv2_api`

The root stack should primarily contain:

- Terraform and provider version requirements.
- AWS provider configuration.
- Input variables.
- Locals.
- Module declarations.
- Outputs.
- Stack-level documentation.

### 2.1 Module Organization

Modules must be organized according to infrastructure responsibilities.

Do not put every resource into one large module. Equally, do not create unnecessary modules for trivial resources that belong to one logical infrastructure component.

Every module should have a clear responsibility and a well-defined interface.

### 2.2 Recommended `ha-web/` Structure

Use the following as the baseline structure:

```text
ha-web/
├── versions.tf
├── providers.tf
├── variables.tf
├── locals.tf
├── main.tf
├── outputs.tf
├── README.md
├── terraform.tfvars.example
│
└── modules/
    ├── ha-vpc/
    │   ├── main.tf
    │   ├── variables.tf
    │   └── outputs.tf
    │
    ├── ha-security/
    │   ├── main.tf
    │   ├── variables.tf
    │   └── outputs.tf
    │
    ├── ha-alb/
    │   ├── main.tf
    │   ├── variables.tf
    │   └── outputs.tf
    │
    ├── ha-iam/
    │   ├── main.tf
    │   ├── variables.tf
    │   └── outputs.tf
    │
    └── ha-compute/
        ├── main.tf
        ├── variables.tf
        └── outputs.tf
```

### Module Responsibilities

**ha-vpc**

Responsible for:

- VPC.
- Public subnets.
- Private application subnets.
- Internet Gateway.
- NAT Gateways.
- Route tables.
- Route table associations.

**ha-security**

Responsible for:

- ALB security group.
- Application security group.
- Required security group rules.
- Least-privilege network traffic configuration.

**ha-alb**

Responsible for:

- Application Load Balancer.
- Target groups.
- Listeners.
- Listener rules where required.

**ha-iam**

Responsible for:

- EC2 IAM role.
- IAM policies.
- Instance profile.
- Permissions required for Systems Manager and ECR access.

**ha-compute**

Responsible for:

- Launch Template.
- Auto Scaling Group.
- Scaling policies.
- CloudWatch alarms where required by the selected scaling design.

### 2.3 Recommended `serverless/` Structure

Use the following as the baseline structure:

```text
serverless/
├── versions.tf
├── providers.tf
├── variables.tf
├── locals.tf
├── main.tf
├── outputs.tf
├── README.md
├── terraform.tfvars.example
│
├── lambda/
│   ├── ingest/
│   └── api/
│
└── modules/
    ├── serverless-storage/
    │   ├── main.tf
    │   ├── variables.tf
    │   └── outputs.tf
    │
    ├── serverless-ingest/
    │   ├── main.tf
    │   ├── variables.tf
    │   └── outputs.tf
    │
    └── serverless-api/
        ├── main.tf
        ├── variables.tf
        └── outputs.tf
```

### Module Responsibilities

**serverless-storage**

Responsible for:

- S3 bucket.
- S3 encryption.
- S3 Block Public Access.
- DynamoDB table.
- DynamoDB billing configuration.

**serverless-ingest**

Responsible for:

- Ingest Lambda function.
- Lambda execution role and permissions.
- S3 event notification.
- Lambda permission allowing the intended S3 bucket to invoke the function.

**serverless-api**

Responsible for:

- API Lambda function.
- API Gateway HTTP API.
- Lambda integration.
- API routes.
- API stage.
- Lambda invoke permissions.

The two Terraform stacks must remain independently deployable and retain separate state boundaries.

---

## 3. Module Connectivity and Dependencies

Modules must be properly connected.

A module must expose the outputs required by other modules through `outputs.tf`.

The consuming module must receive those values through explicitly declared input variables.

Never hardcode resource IDs between modules.

For example, the security module should receive the VPC ID from the VPC module:

```hcl
module "ha_vpc" {
  source = "./modules/ha-vpc"

  project_name = var.project_name
  environment  = var.environment
  aws_region   = var.aws_region
  vpc_cidr     = var.vpc_cidr
}

module "ha_security" {
  source = "./modules/ha-security"

  project_name = var.project_name
  environment  = var.environment
  vpc_id       = module.ha_vpc.vpc_id
}
```

The same principle applies to all module relationships.

For example:

- The security module receives the VPC ID.
- The ALB module receives public subnet IDs and the ALB security group ID.
- The compute module receives private subnet IDs, the application security group ID, target group ARN, and instance profile where required.
- The serverless ingest module receives the S3 bucket and DynamoDB table information.
- The serverless API module receives the DynamoDB table information required by the API Lambda.

Avoid circular dependencies.

Prefer explicit references that naturally establish Terraform dependencies. Do not add unnecessary `depends_on` declarations.

---

## 4. Mandatory Naming Convention

All resources must follow a consistent naming convention throughout the project.

### 4.1 Terraform Naming

Use `snake_case` for:

- Resource labels.
- Variables.
- Locals.
- Outputs.
- Module block identifiers.

Examples:

```hcl
module "ha_vpc" {}

module "ha_alb" {}

module "ha_compute" {}

module "serverless_storage" {}
```

Use `kebab-case` for module directory names:

```text
ha-vpc/
ha-security/
ha-alb/
ha-compute/
serverless-storage/
serverless-ingest/
serverless-api/
```

### 4.2 AWS Resource Naming

Use a predictable naming format:

```text
<project>-<stack>-<component>-<environment>
```

Examples:

```text
aws-ha-serverless-ha-vpc-dev
aws-ha-serverless-ha-alb-dev
aws-ha-serverless-ha-app-asg-dev
aws-ha-serverless-serverless-ingest-dev
```

Use a shared naming local where appropriate:

```hcl
locals {
  name_prefix = "${var.project_name}-${var.stack_name}-${var.environment}"
}
```

Resource-specific names should extend the shared prefix.

Respect AWS naming restrictions, including maximum lengths and permitted characters.

For globally unique resources such as S3 buckets, use a configurable unique suffix.

Do not introduce inconsistent abbreviations or unrelated naming styles.

If the assignment explicitly requires a particular resource name, follow the assignment.

---

## 5. Mandatory AWS Name Tags

**Every taggable AWS resource must have a meaningful AWS tag with the exact key `Name`.**

This is particularly important for EC2 instances.

The EC2 console's Name column is populated from the actual AWS resource tag:

```text
Key:   Name
Value: aws-ha-serverless-ha-app-dev
```

A Terraform resource label is not an AWS Name tag.

A module name is not an AWS Name tag.

An Auto Scaling Group name alone does not guarantee that launched EC2 instances display the desired name in the EC2 console.

### 5.1 Common Tags

Use shared common tags for project-wide metadata.

Example:

```hcl
locals {
  common_tags = {
    Project     = "aws-ha-serverless"
    Environment = var.environment
    ManagedBy   = "Terraform"
  }
}
```

### 5.2 Resource-Specific Name Tags

Every taggable resource must receive its own meaningful `Name` tag.

Example:

```hcl
tags = merge(local.common_tags, {
  Name = "${local.name_prefix}-vpc"
})
```

Use the appropriate tagging argument for each AWS resource.

Do not assume that tags on a parent resource automatically propagate to related resources.

Do not allow common tags to overwrite a resource-specific `Name` value.

### 5.3 EC2 Instance Name Visibility

This requirement must be handled explicitly for instances launched through an Auto Scaling Group.

Configure the Launch Template to apply tags to the actual EC2 instances.

Example:

```hcl
resource "aws_launch_template" "ha_app" {
  # Other launch template configuration.

  tag_specifications {
    resource_type = "instance"

    tags = merge(var.common_tags, {
      Name = "${var.name_prefix}-app"
    })
  }
}
```

Configure Auto Scaling Group tag propagation where appropriate:

```hcl
tag {
  key                 = "Name"
  value               = "${var.name_prefix}-app"
  propagate_at_launch = true
}
```

Use syntax compatible with the pinned AWS provider version.

Avoid conflicting or duplicated tag definitions.

**The final configuration must ensure that newly launched EC2 instances receive the actual `Name` tag.**

Do not claim that the name is visible in the EC2 console until the user has deployed the configuration and provided evidence from the console.

---

## 6. Terraform Best Practices

All Terraform configurations must follow established Terraform and AWS best practices.

### Version Management

- Pin a compatible Terraform version range.
- Pin the AWS provider version.
- Avoid unconstrained provider versions.
- Keep provider configuration in the root stack.
- Make the AWS region configurable through a variable.
- Follow the project region requirement of `eu-west-2`, unless the user authorizes a change.

### Variables and Outputs

- Every input variable must have an explicit type.
- Provide meaningful descriptions.
- Use sensible defaults where appropriate.
- Add validation rules for constrained inputs.
- Document outputs.
- Expose only useful values.
- Never expose credentials or secrets through outputs.

### Resource Management

- Use `for_each` with stable keys where appropriate.
- Avoid unnecessary resource duplication.
- Avoid unnecessary `depends_on`.
- Avoid provisioners unless there is a compelling and documented reason.
- Avoid hardcoded AWS resource IDs.
- Use data sources or variables when appropriate.
- Use lifecycle rules only when their behavior is justified.

### Security

- Apply least-privilege IAM permissions.
- Do not expose application instances directly to the internet.
- Do not expose unnecessary inbound ports.
- Keep secrets out of Terraform files.
- Enable S3 Block Public Access.
- Enable appropriate encryption.
- Scope Lambda permissions to the intended services and resources.
- Follow the project's SSM-based instance management approach.
- Do not introduce SSH access or key pairs unless the user explicitly changes the requirement.

### State and Secrets

- Preserve separate Terraform state boundaries for `ha-web/` and `serverless/`.
- Never commit Terraform state files.
- Never commit real `.tfvars` files containing sensitive values.
- Never commit credentials, access keys, private keys, or secrets.
- Provide `terraform.tfvars.example` where useful.
- Ensure sensitive files are covered by `.gitignore`.

### Cost Awareness

Consider the cost implications of:

- NAT Gateways.
- Application Load Balancers.
- EC2 Auto Scaling Groups.
- CloudWatch resources.
- S3 storage.
- Lambda execution.
- DynamoDB billing.

Do not silently remove required infrastructure to reduce cost. Explain the trade-off and ask the user before changing assignment requirements.

---

## 7. Project-Specific Infrastructure Requirements

### 7.1 HA Web Stack

The `ha-web/` stack must follow the project architecture and assignment requirements.

It must include:

- One VPC.
- Public and private subnets across two Availability Zones.
- Internet Gateway.
- One NAT Gateway per AZ.
- Appropriate route tables and associations.
- Internet-facing Application Load Balancer.
- Application target group and listener.
- Private application instances.
- Auto Scaling Group.
- Launch Template.
- CPU target-tracking scaling policy.
- EC2 IAM role and instance profile.
- Systems Manager management access.
- Required ECR image retrieval permissions.

The Auto Scaling Group must use:

```text
Minimum capacity: 2
Maximum capacity: 4
```

The application must use the project ECR repository:

```text
nodejs-cicd-app
```

The configured image tag is:

```text
latest
```

The application listens on:

```text
Port: 3000
Host: 0.0.0.0
```

Do not add SSH ingress or EC2 key pairs.

Security group traffic must follow the intended flow:

```text
Internet
   |
   v
Application Load Balancer
   |
   v
Private EC2 Instances
```

Only the ALB should be allowed to reach the application port on the instances.

### 7.2 Serverless Stack

The `serverless/` stack must implement the required event-driven architecture.

The ingestion flow:

```text
S3 Object Upload
       |
       v
S3 Event Notification
       |
       v
Ingest Lambda
       |
       v
DynamoDB Metadata Table
```

The API flow:

```text
Client Request
      |
      v
API Gateway HTTP API
      |
      v
API Lambda
      |
      v
DynamoDB Metadata Table
```

Required API routes:

```text
GET /files
GET /files/{id}
```

Requirements:

- S3 bucket must be private.
- S3 Block Public Access must be enabled.
- S3 encryption must be configured.
- DynamoDB must use on-demand billing.
- Lambda functions must use Python.
- Lambda execution roles must follow least privilege.
- S3 invocation permission must be scoped to the intended bucket.
- API Gateway invocation permission must be appropriately scoped.
- Lambda environment variables must match the actual resource names and code.

Use a currently supported AWS Lambda Python runtime. Verify the selected runtime against current AWS documentation or project references before implementing it.

Do not invent application behavior, metadata attributes, partition keys, or API response formats. Align Terraform with the actual Lambda code and assignment.

---

## 8. Module File Standards

Each meaningful module should contain:

```text
main.tf
variables.tf
outputs.tf
```

A README should also be included where the module's responsibility or interface needs explanation.

### main.tf

Contains the module's resource declarations and related configuration.

### variables.tf

Contains all module inputs, with:

- Explicit types.
- Descriptions.
- Sensible defaults where appropriate.
- Validation where useful.

### outputs.tf

Contains outputs required by the root stack or other consumers.

Every output must have a clear description.

Do not expose sensitive values unnecessarily.

---

## 9. Implementation Workflow

Follow this sequence whenever writing or modifying Terraform.

### Step 1: Understand

- Read project instructions.
- Inspect existing Terraform files.
- Understand the architecture.
- Identify the modules involved.
- Identify dependencies between modules.

### Step 2: Present the Plan

Before changing files, explain:

- What will be created or modified.
- Which modules are involved.
- Which resources belong in each module.
- How modules will connect.
- What naming convention will be used.
- How AWS Name tags will be applied.
- Any assumptions or unresolved decisions.

Ask for clarification when a decision materially changes the requested architecture.

### Step 3: Scaffold

Create the required directories and files.

Ensure all managed resources are inside modules.

Keep the root stack focused on configuration and module composition.

### Step 4: Implement

Write complete Terraform configurations.

Ensure:

- All module inputs are declared.
- All required outputs are exposed.
- Module dependencies are connected.
- Naming is consistent.
- AWS Name tags are present.
- EC2 instance tags are configured through the Launch Template and Auto Scaling Group as appropriate.
- Security requirements are respected.
- The configuration matches the assignment.

### Step 5: Static Review

Review the written files without executing Terraform.

Check for:

- Missing variables.
- Missing outputs.
- Incorrect module references.
- Circular dependencies.
- Inconsistent naming.
- Missing Name tags.
- Missing EC2 instance tag propagation.
- Incorrect resource relationships.
- Unnecessary permissions.
- Hardcoded IDs.
- Exposed secrets.
- Assignment deviations.

### Step 6: Handoff

After implementation, hand the configuration to:

- `terraform-review`
- `aws-security-review`
- `aws-architecture-review`, when architecture changes are involved.

Address their findings through file edits, subject to the user's project workflow and approval rules.

### Step 7: User Verification

Provide the user with the commands needed to verify the configuration.

Explain what each command does and what successful output should look like.

The user executes all commands.

---

## 10. Command Execution Restrictions

**The agent must never execute project commands.**

The following commands are for the user only:

```bash
terraform fmt -recursive
terraform init
terraform validate
terraform plan
terraform apply
terraform destroy
```

The agent must also never:

- Execute AWS CLI commands.
- Query or modify live AWS resources.
- Deploy infrastructure.
- Run application tests or builds.
- Apply or destroy Terraform resources.
- Commit or push Git changes.
- Use `-auto-approve`.
- Claim that infrastructure has been deployed without user-provided evidence.

The agent may prepare commands and explain:

- Why each command is needed.
- Where the user should execute it.
- What successful output should look like.
- What common errors mean.
- How to troubleshoot errors shared by the user.

The user alone is responsible for command execution and infrastructure changes.

---

## 11. Documentation and Handoff

After completing Terraform changes, provide a concise implementation report.

Include:

1. Files created.
2. Files modified.
3. Modules created.
4. Resources implemented.
5. Module connections and dependencies.
6. Naming convention used.
7. AWS Name tag implementation.
8. EC2 instance Name tag implementation.
9. Security considerations.
10. Assumptions and pending decisions.
11. Commands the user should execute.
12. Items requiring review by other skills.

Do not claim that formatting, initialization, validation, planning, deployment, or testing has succeeded unless the user provides the corresponding output.

---

## 12. Final Completion Checklist

Before declaring the Terraform implementation complete, verify the following through static inspection:

### Architecture and Modules

- [ ] All managed AWS resources are declared inside Terraform modules.
- [ ] Root stacks contain module calls rather than direct managed resource declarations.
- [ ] Modules have clear responsibilities.
- [ ] Module inputs and outputs are explicitly defined.
- [ ] Modules are properly connected.
- [ ] No circular dependencies exist.
- [ ] Separate stack state boundaries are preserved.

### Naming and Tags

- [ ] Terraform identifiers use consistent `snake_case`.
- [ ] Module directories use consistent `kebab-case`.
- [ ] AWS resource names follow the project naming convention.
- [ ] Every taggable AWS resource has a meaningful `Name` tag.
- [ ] Common tags are applied consistently.
- [ ] Resource-specific Name values are not overwritten.
- [ ] EC2 instances launched by the Auto Scaling Group receive the actual `Name` tag.
- [ ] The EC2 Name tag is configured so the instance can display its name in the EC2 console.

### Terraform Quality

- [ ] Terraform and provider versions are constrained.
- [ ] Variables have explicit types and descriptions.
- [ ] Outputs are documented.
- [ ] Resource references are connected correctly.
- [ ] No unnecessary hardcoded IDs exist.
- [ ] No secrets are included.
- [ ] No unnecessary provisioners or dependencies exist.

### Security and Assignment Compliance

- [ ] IAM permissions follow least privilege.
- [ ] Network access follows the intended architecture.
- [ ] S3 security requirements are implemented.
- [ ] Lambda permissions are appropriately scoped.
- [ ] The HA web stack matches the assignment.
- [ ] The serverless stack matches the assignment.
- [ ] Cost implications are considered.
- [ ] No infrastructure outside the assignment scope has been introduced.

### Execution Boundaries

- [ ] No Terraform command was executed by the agent.
- [ ] No AWS CLI command was executed by the agent.
- [ ] No deployment or infrastructure modification was performed.
- [ ] No test was claimed successful without user-provided evidence.
- [ ] No apply or destroy operation was performed.

Any unchecked item must be reported as pending, incomplete, or requiring user input.

---

## 13. End-to-End Skill Coordination

`tf-scaffold` is the Terraform authoring skill. It owns creation and modification of Terraform modules and stack composition, while the other specialist skills review or consume that work. The normal Terraform handoff is:

1. `implementation-guide` defines the milestone and requests the Terraform work.
2. `tf-scaffold` inspects the repository and writes or updates the required module-first Terraform configuration.
3. `terraform-review` statically reviews the resulting Terraform.
4. `aws-security-review` reviews IAM, network, S3, Lambda, and secrets implications.
5. `aws-architecture-review` reviews material architecture changes or unresolved design decisions.
6. `tf-scaffold` corrects Terraform findings that belong to the Terraform implementation, without executing Terraform.
7. `implementation-guide` prepares the user verification handoff.

Do not skip a required review because a previous skill already inspected the same files. Reviews may overlap, but each skill retains its own responsibility. Never treat a static review as proof that Terraform has been initialized, validated, planned, applied, or deployed.

The same workflow applies to both `ha-web/` and `serverless/`, and their separate state boundaries must remain intact.

## Final Principle

Build Terraform as a connected system of reusable modules, not as a collection of unrelated resource declarations.

Every resource must belong to a module. Every module must have a clear responsibility. Every dependency must be explicit. Every taggable AWS resource must have a meaningful `Name` tag.

Most importantly, ensure that EC2 instances launched by the Auto Scaling Group receive a real AWS `Name` tag so their names are visible in the EC2 console.

Write the infrastructure carefully, follow the assignment, preserve the user's control over execution, and never claim success without evidence.
