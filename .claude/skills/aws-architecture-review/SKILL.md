---
name: aws-architecture-review
description: Statically reviews the aws-ha-serverless AWS design, including multi-AZ networking, ALB/ASG, and S3/Lambda/DynamoDB/API flows.
---
# AWS Architecture Review

## Mission
Assess whether the proposed or coded design meets the assignment, has coherent traffic/data flows, and is appropriately available, secure by design, and cost-aware. This is a static design review, not a deployment or live AWS audit.

## Context
Read CLAUDE.md, assignment brief, stack READMEs, diagrams, Terraform, and relevant application code. State what was inspected and what was unavailable. Respect fixed settings, including `eu-west-2`, two AZs, and separate stacks.

## Web stack review (`ha-web/`)
Review VPC CIDR/subnet layout; two-AZ public/private subnet placement; IGW, route tables and one NAT Gateway per AZ; ALB placement/listeners/target group/health checks; Launch Template and ASG; min 2/max 4; CPU target tracking; private application instances; ECR access and container startup; SSM access without SSH/key pairs; security-group traffic paths; and failure behavior if an instance/AZ is unavailable. Check port 3000 and `0.0.0.0` binding where relevant. Do not assume the image exists or the app is deployed.

## Serverless review (`serverless/`)
Review S3 bucket protection/encryption; object-created notification; permission for S3 to invoke `ingest`; `ingest` DynamoDB write permissions; metadata schema and stable identifier; duplicate event/retry considerations; API Gateway HTTP API integration and invoke permission; `GET /files` and `GET /files/{id}`; `api` read permissions; missing-record/error behavior; pagination considerations; and separation of responsibilities. Separate mandatory requirements from optional enhancements.

## Cross-cutting review
Review dependencies, least privilege, logs/observability, encryption, NAT/ALB costs, independent stack lifecycles, and documentation/diagram accuracy.

## Method
1. State scope and inspected files.
2. Summarize traffic and data flows.
3. Map design to requirements.
4. Identify missing links, contradictions, and assumptions.
5. Classify findings: CRITICAL, HIGH, MEDIUM, LOW, INFO.
6. For each finding provide component/path, evidence, impact, correction, and whether it blocks the next milestone.
7. Provide a coverage matrix and unresolved questions.

Use `NOT REVIEWED` when evidence is unavailable. Do not report a configuration as absent if its file was not inspected.

## Deliverables
Architecture summary, flow descriptions, requirement matrix, severity-ranked findings, prioritized recommendations, user decisions, and status: `APPROVED`, `APPROVED WITH FINDINGS`, or `NOT APPROVED`. Approval means only that the inspected design appears consistent; it does not prove deployment or testing.

## Coordination
Route Terraform authoring or implementation concerns to `tf-scaffold`; route static Terraform review concerns to `terraform-review`, security concerns to `aws-security-review`, sequencing to `implementation-guide`, and verified design decisions/evidence to `doc-writer`. Do not rewrite files unless asked.

## Boundaries
No commands, AWS queries, deployment, infrastructure changes, or claims about live availability. Follow CLAUDE.md.
