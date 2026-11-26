
# CLAUDE.md — AWS High Availability and Serverless Project

## 1. Project Overview

This repository contains an AWS infrastructure and serverless application project for the Bincom Infra/Cloud class assignment.

The project demonstrates:

1. Multi-AZ high availability and fault tolerance.
2. Load balancing and auto-scaling for a web application.
3. Event-driven serverless file processing using Amazon S3, AWS Lambda, and DynamoDB.
4. HTTP API integration using API Gateway and AWS Lambda.
5. Infrastructure provisioning using Terraform.
6. Technical implementation documentation in Microsoft Word format.

The project must be implemented in a modular, secure, maintainable, and cost-conscious manner.

## 2. Project Structure

The repository is organized into two independent Terraform stacks:

```text
aws-ha-serverless/
│
├── .claude/
│   └── skills/
│       ├── doc-writer/
│       ├── implementation-guide/
│       ├── aws-architecture-review/
│       ├── terraform-review/
│       ├── tf-scaffold/
│       ├── aws-security-review/
│       ├── aws-testing-guide/
│       ├── screenshot-manager/
│       └── final-delivery-review/
│
├── references/
│   └── Assignment_2_CICD_Documentation.docx
│
├── docs/
│   ├── screenshots/
│   └── assignment-documentation.docx
│
├── ha-web/
│   ├── main.tf
│   ├── variables.tf
│   ├── outputs.tf
│   ├── versions.tf
│   ├── terraform.tfvars.example
│   ├── README.md
│   └── modules/
│       ├── ha-vpc/
│       ├── ha-security/
│       ├── ha-alb/
│       ├── ha-iam/
│       └── ha-compute/
│
├── serverless/
│   ├── main.tf
│   ├── variables.tf
│   ├── outputs.tf
│   ├── versions.tf
│   ├── lambda/
│   │   ├── ingest/
│   │   └── api/
│   ├── README.md
│   └── modules/
│       ├── serverless-storage/
│       ├── serverless-ingest/
│       └── serverless-api/
│
└── CLAUDE.md
```

Do not assume every listed file or directory already exists. Inspect the repository before creating or modifying files.

Keep the two Terraform stacks independent, with separate state files and deployment lifecycles.

## 3. AWS Environment and Global Configuration

Use the following project configuration unless the user explicitly approves a change:

| Configuration | Value |
|---|---|
| Cloud provider | AWS |
| AWS region | eu-west-2 |
| Availability Zones | Two |
| Infrastructure as Code | Terraform |
| Web application | Node.js container |
| Container registry | Amazon ECR |
| Container image repository | nodejs-cicd-app |
| Application port | 3000 |
| Serverless runtime | Latest supported Python runtime |
| Database | Amazon DynamoDB |
| API type | API Gateway HTTP API |
| Documentation format | Microsoft Word (.docx) |

### General Infrastructure Requirements

- Use two Availability Zones for the high-availability architecture.
- Use one NAT Gateway per Availability Zone.
- Use public subnets for internet-facing resources.
- Use private subnets for application resources.
- Avoid exposing application instances directly to the internet.
- Use Application Load Balancer for incoming web traffic.
- Use Auto Scaling Group for application instance management.
- Use Systems Manager for instance administration.
- Do not configure SSH access or create EC2 key pairs for this architecture.
- Use Terraform variables for configurable values.
- Avoid hardcoded AWS account IDs.
- Use provider default tags where appropriate.
- Pin Terraform provider versions.
- Apply consistent resource naming and tagging.

Default project tag:

```hcl
Project = "aws-ha-serverless"
```

## 4. Stack One: High Availability Web Application

Location: `ha-web/`

### Architecture Requirements

Build a highly available web application architecture containing:

- One VPC.
- Two public subnets across two Availability Zones.
- Two private application subnets across two Availability Zones.
- Internet Gateway.
- One NAT Gateway per Availability Zone.
- Appropriate route tables and associations.
- Application Load Balancer.
- Target Group and Listener.
- Auto Scaling Group.
- Launch Template.
- IAM instance role and instance profile.
- Systems Manager access.
- Security groups with least-privilege rules.

### Application Requirements

The application must:

- Use the Node.js container image from ECR.
- Use repository name `nodejs-cicd-app`.
- Use image tag `latest`.
- Listen on port `3000`.
- Bind to `0.0.0.0`.
- Display `Hello World`.
- Display the container hostname so requests can demonstrate load distribution.

### Auto Scaling Requirements

Configure:

- Minimum capacity: 2 instances.
- Maximum capacity: 4 instances.
- Desired capacity appropriate to the architecture.
- CPU-based target tracking scaling policy.

Ensure the architecture can distribute incoming traffic across healthy application instances.

## 5. Stack Two: Serverless File Processing Application

Location: `serverless/`

The serverless application consists of two independent workflows.

### 5.1 S3 Event-Driven File Ingestion

Implement the following flow:

```text
User uploads a file
        |
        v
Amazon S3 Bucket
        |
        v
S3 ObjectCreated Event
        |
        v
Ingest Lambda Function
        |
        v
Amazon DynamoDB
```

Requirements:

- Create an S3 bucket.
- Enable S3 Block Public Access.
- Enable server-side encryption.
- Configure an S3 event notification for object creation.
- Create a Python Lambda function named `ingest`.
- Grant the Lambda function only the permissions it needs.
- Store uploaded file metadata in DynamoDB.

The metadata should contain useful information such as:

- File ID.
- Object key.
- Bucket name.
- File size, where available.
- Content type, where available.
- Upload timestamp.

Do not store file contents in DynamoDB.

### 5.2 HTTP API for File Metadata

Implement the following flow:

```text
Client
  |
  v
API Gateway HTTP API
  |
  v
API Lambda Function
  |
  v
Amazon DynamoDB
```

Requirements:

- Create an API Gateway HTTP API.
- Create a Python Lambda function named `api`.
- Configure the required Lambda integration and permissions.
- Implement the following routes:

| HTTP Method | Route | Purpose |
|---|---|---|
| GET | /files | Retrieve file metadata |
| GET | /files/{id} | Retrieve metadata for one file |

- Return appropriate HTTP status codes.
- Handle missing records and invalid requests.
- Use DynamoDB on-demand billing.
- Follow least-privilege IAM practices.

## 6. Terraform Standards

All infrastructure must be defined using Terraform.

### Configuration Standards

- Keep resources logically organized.
- Separate reusable variables from resource definitions.
- Define outputs for useful infrastructure information.
- Pin Terraform and provider versions.
- Use meaningful resource names.
- Avoid unnecessary duplication.
- Avoid hardcoded credentials and secrets.
- Keep sensitive configuration out of version control.
- Use separate Terraform state for `ha-web/` and `serverless/`.

### Required Static Checks

Prepare the following commands for the user to execute:

```bash
terraform fmt -recursive
terraform validate
terraform plan
```

The AI agent may inspect the configuration and explain the expected outcome, but must not execute these commands.

### Terraform Safety

Never:

- Run `terraform apply`.
- Run `terraform destroy`.
- Run Terraform commands that modify infrastructure.
- Approve infrastructure changes on the user's behalf.
- Use `-auto-approve`.
- Modify existing infrastructure without explicit user authorization.

The user must review every plan and personally execute any approved infrastructure operation.

## 7. Security Requirements

All architecture and configuration decisions must consider security.

Review the following areas:

### IAM

- Apply least-privilege permissions.
- Avoid wildcard permissions unless technically necessary and justified.
- Separate IAM roles for different services.
- Restrict Lambda permissions to required resources.

### Networking

- Keep application instances in private subnets.
- Restrict security group ingress and egress appropriately.
- Allow application traffic through the load balancer.
- Avoid unnecessary public access.

### Data Protection

- Enable S3 encryption.
- Enable S3 Block Public Access.
- Avoid storing secrets in source code.
- Protect Terraform state.
- Do not commit credentials, access keys, or sensitive configuration.

### EC2 Administration

- Use Systems Manager instead of SSH.
- Do not expose port 22.
- Avoid creating or storing EC2 private keys.

## 8. Cost Management

This is an educational project, so cost must be considered throughout implementation.

- Explain the cost implications of NAT Gateways.
- Explain the cost implications of Application Load Balancers.
- Consider EC2 instance types and running duration.
- Explain potential Lambda, S3, DynamoDB, and API Gateway costs.
- Avoid creating unnecessary resources.
- Identify resources that continue to incur charges when instances are stopped.
- Remind the user to review resources after testing.
- Do not destroy infrastructure without explicit user approval.

Where possible, recommend cost-conscious configurations without compromising assignment requirements.

## 9. AI Skills and Responsibilities

The repository contains nine specialized skills.

Each skill must respect this `CLAUDE.md` file and must not override its execution restrictions.

### 9.1 Implementation Guide

Location:

`.claude/skills/implementation-guide/SKILL.md`

Responsibilities:

- Understand the assignment requirements.
- Break the project into logical implementation phases.
- Identify dependencies between resources.
- Explain what needs to be implemented at each phase.
- Provide commands for the user to execute.
- Explain expected outputs and possible errors.
- Identify the next implementation milestone.

The implementation guide coordinates the overall workflow.

### 9.2 AWS Architecture Review

Location:

`.claude/skills/aws-architecture-review/SKILL.md`

Responsibilities:

- Review the proposed AWS architecture.
- Verify the logical design of the VPC and subnets.
- Review Availability Zone distribution.
- Review network traffic flow.
- Assess high availability and fault tolerance.
- Review load balancing and auto-scaling design.
- Review the serverless event flow.
- Identify architectural weaknesses and recommend improvements.

The skill must perform static architectural reviews and must not deploy resources.

### 9.3 Terraform Review

Location:

`.claude/skills/terraform-review/SKILL.md`

Responsibilities:

- Inspect Terraform configuration files.
- Review resource dependencies.
- Identify syntax and configuration problems.
- Review variables, outputs, providers, and modules.
- Identify unnecessary duplication.
- Review naming conventions and tagging.
- Identify potential Terraform errors.
- Recommend corrections.

The skill must not execute Terraform commands.

### 9.4 AWS Security Review

Location:

`.claude/skills/aws-security-review/SKILL.md`

Responsibilities:

- Review IAM roles and policies.
- Review security group rules.
- Review public and private subnet exposure.
- Review S3 bucket security.
- Review encryption settings.
- Review Lambda execution permissions.
- Identify overly permissive access.
- Recommend least-privilege configurations.

The skill must not modify AWS resources or apply infrastructure changes.

### 9.5 AWS Testing Guide

Location:

`.claude/skills/aws-testing-guide/SKILL.md`

Responsibilities:

- Prepare testing procedures for each project component.
- Provide commands for the user to execute.
- Explain expected results.
- Explain how to interpret successful and failed tests.
- Prepare tests for high availability and load distribution.
- Prepare tests for S3 event processing.
- Prepare tests for DynamoDB metadata.
- Prepare tests for API Gateway endpoints.
- Track test results supplied by the user.

The skill must never execute tests or commands itself.

### 9.6 Screenshot Manager

Location:

`.claude/skills/screenshot-manager/SKILL.md`

Responsibilities:

- Identify the screenshots required for the assignment.
- Create screenshot checkpoints for each implementation phase.
- Tell the user exactly where to navigate.
- Explain what must be visible in each screenshot.
- Suggest meaningful screenshot filenames.
- Provide appropriate figure captions.
- Track screenshots supplied by the user.
- Coordinate screenshot placement with `doc-writer`.

Never fabricate, generate, or claim to have captured evidence from the AWS console.

### 9.7 Doc Writer

Location:

`.claude/skills/doc-writer/SKILL.md`

Responsibilities:

- Create and maintain the assignment report in Microsoft Word format.
- Use the supplied sample Word document as the authoritative formatting reference.
- Follow the sample's structure, writing style, and presentation as closely as possible.
- Document implementation activities as they happen.
- Include relevant explanations and resource descriptions.
- Insert screenshots supplied by the user.
- Add appropriate figure numbers and captions.
- Keep the document consistent and professional.
- Update the same Word document throughout the project.

Primary output:

`docs/assignment-documentation.docx`

The Word document is the official assignment report. Markdown may be used for internal notes, but not as a replacement for the final report.

Never fabricate implementation details, screenshots, test results, or deployment outcomes.

### 9.8 TF Scaffold

Location:

`.claude/skills/tf-scaffold/SKILL.md`

Responsibilities:

- Own Terraform authoring and modification for `ha-web/` and `serverless/`.
- Enforce the mandatory module-first architecture.
- Keep root stacks focused on provider/configuration, variables, locals, module calls, and outputs.
- Define clear module responsibilities and explicit input/output interfaces.
- Enforce consistent Terraform identifiers, AWS resource naming, common tags, and meaningful `Name` tags.
- Ensure ASG-launched EC2 instances receive the intended AWS `Name` tag through Launch Template/ASG configuration.
- Preserve independent Terraform state boundaries for the two stacks.
- Perform static self-review before handing Terraform to `terraform-review`, `aws-security-review`, and `aws-architecture-review` where applicable.
- Never execute Terraform, AWS CLI, builds, tests, deployment, destruction, or Git operations.

The skill is the Terraform authoring counterpart to `terraform-review`: `tf-scaffold` writes and corrects Terraform; `terraform-review` independently reviews it. Findings that require Terraform changes are routed back to `tf-scaffold`.

### 9.9 Final Delivery Review

Location:

`.claude/skills/final-delivery-review/SKILL.md`

Responsibilities:

- Compare the completed project against the assignment requirements.
- Review both Terraform stacks.
- Check the architecture and security reviews.
- Check implementation and testing evidence.
- Verify that screenshots support the documented claims.
- Review the final Word document.
- Identify missing deliverables.
- Produce a final checklist of completed, pending, and failed requirements.

Do not claim that a requirement is complete without supporting evidence.

## 10. Required Implementation Workflow

Follow this workflow unless the user explicitly requests a different sequence.

### Phase 1: Project Assessment

Use `implementation-guide` to:

- Inspect the repository structure.
- Read the assignment requirements.
- Identify existing implementation work.
- Identify missing components.
- Prepare an implementation roadmap.

Do not overwrite existing work without inspecting it.

### Phase 2: Architecture Design

Use `aws-architecture-review` to:

- Review the proposed architecture.
- Identify dependencies.
- Check multi-AZ design.
- Check traffic flow.
- Review the serverless architecture.

Resolve significant architectural issues before implementation.

### Phase 3: Terraform Development

Use `tf-scaffold` as the Terraform authoring skill. It must inspect the existing repository and assignment requirements, create or modify the required modules, connect module inputs/outputs, and enforce the project naming/tagging standards.

Then use `terraform-review` for an independent static Terraform review and `aws-security-review` for security-sensitive configuration. Use `aws-architecture-review` when the Terraform changes introduce or alter material architecture decisions.

If a review identifies a Terraform implementation defect, route the correction back to `tf-scaffold`, then repeat the affected review before moving to user verification.

Do not run project commands.

Terraform handoff sequence:

`implementation-guide` -> `tf-scaffold` -> `terraform-review` + `aws-security-review` (+ `aws-architecture-review` when needed) -> `tf-scaffold` corrections if required -> `implementation-guide` -> user verification.

Each skill must state what it inspected, what it changed or found, what remains unverified, and which skill owns the next action. No skill may treat another skill's static review as proof of deployment or testing.

### Phase 4: User-Led Implementation

The user executes all commands and infrastructure operations.

The AI agents may:

- Prepare commands.
- Explain command arguments.
- Explain expected outputs.
- Help interpret outputs pasted by the user.
- Suggest corrections to configuration files.

The AI agents must wait for user-provided results before claiming successful execution.

### Phase 5: Testing and Verification

Use `aws-testing-guide` to prepare the testing procedures.

The user executes all tests and shares the results.

Classify results as:

- VERIFIED: Supported by actual user-provided evidence.
- PENDING: Not yet tested or evidence has not been supplied.
- FAILED: A test or requirement has demonstrably failed.

### Phase 6: Screenshot Collection

Use `screenshot-manager` to coordinate evidence collection.

For every screenshot checkpoint, specify:

1. What the screenshot demonstrates.
2. Where the user should navigate.
3. What must be visible.
4. The suggested filename.
5. The documentation section.
6. The proposed figure caption.

The user captures and supplies the screenshots.

### Phase 7: Documentation

Use `doc-writer` throughout the project, not only at the end.

Update:

`docs/assignment-documentation.docx`

Document completed milestones and clearly identify pending work.

### Phase 8: Final Review

Use `final-delivery-review` to check:

- Assignment coverage.
- Architecture completeness.
- Terraform configuration.
- Security.
- Testing evidence.
- Screenshots.
- Documentation.
- Deliverables.

Produce a final completion report.

## 11. Mandatory Execution Restrictions

These restrictions apply to every AI agent, skill, subagent, and automated workflow in this repository.

### The User Owns All Project Execution

The user alone executes:

- Shell commands related to project implementation.
- Terraform commands.
- AWS CLI commands.
- Infrastructure deployment.
- Infrastructure destruction.
- Application builds and deployments.
- Application tests.
- API tests.
- Git commands and commits.
- AWS console operations.
- Screenshot capture.

AI agents must not execute these operations.

### What AI Agents Are Allowed to Do

AI agents may:

- Read and inspect project files.
- Create and edit source code.
- Create and edit Terraform configuration files.
- Review architecture and configurations.
- Prepare commands for the user.
- Explain expected command outputs.
- Diagnose errors using outputs supplied by the user.
- Prepare test procedures.
- Prepare documentation.
- Organize screenshot evidence supplied by the user.
- Create or edit the Word documentation file.

Creating or editing project files is permitted, including Terraform module authoring by `tf-scaffold`, but does not authorize executing those files or applying their changes to AWS.

### Approval Requirements

Before any infrastructure deployment or destruction:

1. The user must receive the proposed Terraform plan.
2. The user must understand the proposed changes.
3. The user must explicitly approve the operation.
4. The user personally executes the operation.

Never interpret a request to prepare, review, or explain infrastructure as permission to deploy it.

Never use `-auto-approve`.

## 12. Git and Sensitive File Protection

Never commit or expose:

- Terraform state files.
- AWS access keys.
- AWS secret access keys.
- `.env` files.
- Private keys.
- `.pem` files.
- `.key` files.
- Sensitive `.tfvars` files.
- Passwords or tokens.

Use `.gitignore` to protect sensitive files.

The user owns all Git operations and commits.

AI agents may recommend Git commands but must not execute them.

Do not add AI attribution to the user's commits or documentation.

## 13. Documentation and Evidence Standards

All documentation must be factual and supported by available evidence.

Never:

- Invent deployment results.
- Invent AWS resource IDs.
- Invent endpoint URLs.
- Invent test results.
- Fabricate screenshots.
- Claim an architecture is deployed when it has only been designed.
- Mark pending work as verified.

Clearly distinguish between:

- Planned architecture.
- Implemented configuration.
- Deployed infrastructure.
- Tested functionality.

When evidence is missing, label the relevant item as PENDING.

## 14. Communication Standards

All agents must communicate in a clear, practical, and beginner-friendly manner.

When guiding the user:

- Explain technical concepts when necessary.
- Break complex work into manageable steps.
- Use exact file paths.
- Provide complete file contents when replacing a file.
- Clearly identify whether the user should create, replace, or edit a file.
- Avoid vague instructions.
- Explain why an action is necessary.
- Provide commands separately from explanations.
- Explain expected outputs.
- Do not overwhelm the user with unrelated information.

Do not assume that the user has executed a command simply because it was suggested.

Do not move to the next implementation phase until the required user action or evidence has been received.

## 15. Completion Criteria

The project is considered ready for submission only when:

- Both Terraform stacks have been reviewed.
- The required architecture has been implemented.
- The serverless workflows have been implemented.
- Security configurations have been reviewed.
- Required tests have been executed by the user.
- Supporting evidence has been collected.
- Required screenshots have been supplied.
- The Word report has been completed.
- The final delivery review has been performed.

The final report must identify:

1. Completed requirements.
2. Pending requirements.
3. Failed requirements, if any.
4. Evidence available.
5. Remaining issues.
6. Final deliverables and their locations.

Once the final review is complete, provide the user with the results and stop. Do not perform additional infrastructure operations.
