# S3 Deployment

Two deployment options are available: **shell scripts** for quick manual deploys, and a **Terraform module** for full infrastructure-as-code provisioning.

## Option 1: Shell Scripts

One-command build and deploy to an existing S3 bucket (with optional CloudFront cache invalidation).

- **`deploy.sh`** — Bash (Linux, macOS, WSL, Git Bash)
- **`deploy.ps1`** — PowerShell (Windows)

### Prerequisites

- AWS CLI v2 installed and configured (`aws configure`)
- An S3 bucket with static website hosting enabled
- (Optional) A CloudFront distribution in front of the bucket

### Usage

#### Bash (Linux / macOS)

```bash
S3_BUCKET=my-statuspage-bucket ./scripts/s3/deploy.sh

# With CloudFront invalidation
S3_BUCKET=my-statuspage-bucket \
CLOUDFRONT_DISTRIBUTION_ID=E1A2B3C4D5E6F7 \
./scripts/s3/deploy.sh
```

#### PowerShell (Windows)

```powershell
$env:S3_BUCKET = "my-statuspage-bucket"
.\scripts\s3\deploy.ps1

# With CloudFront invalidation
$env:S3_BUCKET = "my-statuspage-bucket"
$env:CLOUDFRONT_DISTRIBUTION_ID = "E1A2B3C4D5E6F7"
.\scripts\s3\deploy.ps1
```

### Environment Variables

| Variable | Required | Default | Description |
|---|---|---|---|
| `S3_BUCKET` | yes | — | Name of the S3 bucket to deploy to. |
| `CLOUDFRONT_DISTRIBUTION_ID` | no | — | CloudFront distribution ID. If set, an invalidation is created after upload. |
| `AWS_REGION` | no | `us-east-1` | AWS region for the S3 bucket. |

### What It Does

1. Runs `npm run build` from the project root
2. Syncs `dist/` to the S3 bucket (with `--delete` to remove stale files)
3. If a CloudFront distribution ID is provided, submits a `/*` cache invalidation

## Option 2: Terraform Module

The `terraform/` directory contains a Terraform module that provisions the full AWS infrastructure (S3 bucket, CloudFront distribution, OAC) and deploys the site on every `terraform apply`.

Features:
- S3 bucket with public access blocked (served via CloudFront OAC)
- CloudFront distribution with HTTPS redirect
- Optional custom domain with ACM certificate (DNS validation)
- Optional AWS WAF with managed rule groups and CloudWatch logging
- Configurable geographic restrictions (defaults to US-only whitelist)
- Automatic site build, S3 sync, and CloudFront cache invalidation on apply

```bash
cd scripts/s3/terraform
terraform init
terraform apply -var="bucket_name=my-statuspage-bucket"
```

See [`terraform/README.md`](terraform/README.md) for full variable and output reference.
