---
name: final-delivery-review
description: Performs an evidence-based final readiness review of the aws-ha-serverless assignment, including requirements, Terraform stacks, security, tests, screenshots, and Word documentation.
---
# Final Delivery Review

## Mission
Determine submission readiness by comparing the assignment requirements with actual project files and user-provided evidence. This is a final review and gap analysis, not an execution or deployment skill.

## Context
Read CLAUDE.md, original assignment brief, both stack READMEs, relevant Terraform/application files, specialist review findings, user-provided test outputs, accepted screenshot register/images, and `docs/assignment-documentation.docx`. If material is unavailable, record it as unavailable; do not infer completion.

## Review dimensions

### 1. Assignment coverage
Build a requirement matrix covering, at minimum:
- Multi-AZ VPC and subnet architecture.
- Public/private separation, IGW, and NAT arrangement.
- ALB, ASG, and CPU target tracking.
- ECR `nodejs-cicd-app` container, port 3000, `Hello World`, and hostname.
- SSM administration and no SSH dependency.
- S3 object-created event and Python `ingest` Lambda.
- DynamoDB metadata persistence.
- API Gateway HTTP API and Python `api` Lambda.
- `GET /files` and `GET /files/{id}`.
- Security and documentation deliverables.
Use exact assignment wording where available. Do not add unrelated criteria as mandatory.

### 2. Terraform and source
Check the `tf-scaffold` module-first requirements: every managed AWS resource must be inside a module; root stacks should compose modules; module inputs/outputs and dependencies must be explicit; naming and AWS `Name` tags must be consistent; ASG-launched EC2 instances must receive the intended `Name` tag. Then check independent `ha-web/` and `serverless/` stacks/state, required files, provider/region settings, outputs/READMEs, relevant review findings, and accidental secrets/prohibited files. Do not run Terraform or claim validation passed.

### 3. Architecture and security
Review latest architecture/security findings. Confirm significant issues are resolved or explicitly disclosed. Static review does not prove live security or availability.

### 4. Testing
For every behavior record test, user-reported result, evidence reference, status (`VERIFIED`, `PENDING`, `FAILED`, `NOT APPLICABLE`), and limitations. A planned test is not completed. Verification requires sufficient user-supplied output or screenshot.

### 5. Screenshots
Check required evidence is supplied, readable, identifiable, relevant, correctly captioned/referenced, and free of exposed secrets. Do not fabricate or misrepresent images.

### 6. Word report
Inspect the actual DOCX. Check sample style fidelity (if sample available), assignment coverage, factual narrative, evidence/captions, unsupported claims, placeholders, table/page layout, and whether the document is a valid Word file. Do not claim inspection if it was not possible.

## Status definitions
- `VERIFIED`: supported by inspected files or user evidence; state what kind of verification.
- `PENDING`: incomplete or evidence missing.
- `FAILED`: evidence shows requirement not met.
- `NOT APPLICABLE`: demonstrably outside scope.
- `NOT REVIEWED`: source/evidence unavailable.
Distinguish static code review from live deployment verification.

## Final report
Provide:
1. Overall status: `READY FOR SUBMISSION`, `READY WITH DISCLOSED GAPS`, or `NOT READY`.
2. Executive summary.
3. Requirement matrix: requirement, status, evidence, notes.
4. Blocking issues.
5. Non-blocking issues.
6. Evidence inventory.
7. Deliverables with exact paths.
8. Ordered next actions.

Do not say `READY FOR SUBMISSION` while mandatory requirements are failed, pending, or unsupported. If grading criteria are unavailable, disclose that review is based on supplied brief and CLAUDE.md.

## Coordination
Route Terraform implementation gaps to `tf-scaffold`; route sequencing gaps to `implementation-guide`; design issues to `aws-architecture-review`; Terraform issues to `terraform-review`; security issues to `aws-security-review`; missing test plans to `aws-testing-guide`; screenshot gaps to `screenshot-manager`; report corrections to `doc-writer`. Do not independently rewrite every artifact.

## Boundaries
Follow CLAUDE.md. Never execute commands, tests, Terraform, AWS CLI, Git, deployments, or infrastructure changes. Never fabricate evidence or approve infrastructure operations.
