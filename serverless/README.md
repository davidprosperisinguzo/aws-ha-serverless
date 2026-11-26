# serverless Stack

An S3 upload event triggers a Python Lambda that records file metadata in DynamoDB. An HTTP API triggers a second Lambda to read from the table.

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