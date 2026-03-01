# Status Page — S3 + CloudFront Terraform Module

Provisions an S3 bucket and CloudFront distribution to host the static status page, then builds and uploads the site on every `terraform apply`. Optionally configures a custom domain (ACM certificate) and AWS WAF with CloudWatch logging.

## Prerequisites

- [Terraform](https://developer.hashicorp.com/terraform/install) >= 1.0
- [AWS CLI](https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html) configured with an SSO profile
- Node.js and npm (for `npm run build`)

## Usage

Basic (CloudFront URL only):

```bash
cd scripts/s3/terraform
terraform init
terraform apply -var="bucket_name=my-statuspage-bucket"
```

With custom domain and WAF:

```bash
terraform apply \
  -var="bucket_name=my-statuspage-bucket" \
  -var="domain_name=status.example.com" \
  -var="enable_waf=true"
```

## Variables

| Name           | Description                                                                 | Type     | Default       | Required |
|----------------|-----------------------------------------------------------------------------|----------|---------------|----------|
| `aws_region`   | AWS region for the S3 bucket and CloudFront distribution                    | `string` | `us-east-1`   | no       |
| `bucket_name`  | Name of the S3 bucket for the static status page                            | `string` | —             | **yes**  |
| `aws_profile`  | AWS CLI profile to use for S3 sync and CloudFront invalidation              | `string` | `cc`           | no       |
| `domain_name`  | Custom domain name (e.g. `status.example.com`). Leave empty to skip.        | `string` | `""`           | no       |
| `geo_restriction_type` | CloudFront geo restriction type: `none`, `whitelist`, or `blacklist`   | `string`       | `whitelist`    | no       |
| `geo_restriction_locations` | ISO 3166-1 alpha-2 country codes for the geo restriction         | `list(string)` | `["US"]`       | no       |
| `enable_waf`   | Enable AWS WAF on CloudFront with managed rule groups and CloudWatch logging | `bool`   | `false`        | no       |
| `project_root` | Path to the statuspage project root relative to this terraform directory     | `string` | `../../..`     | no       |

## Outputs

| Name                         | Description                                                        |
|------------------------------|--------------------------------------------------------------------|
| `cloudfront_url`             | CloudFront distribution domain name                                |
| `s3_bucket_name`             | Name of the S3 bucket                                              |
| `cloudfront_distribution_id` | CloudFront distribution ID                                         |
| `acm_certificate_arn`        | ARN of the ACM certificate (when `domain_name` is set)             |
| `acm_validation_records`     | DNS CNAME records to create for ACM certificate validation         |
| `custom_domain_cname`        | CNAME record to point your custom domain to CloudFront             |

## Custom Domain Setup

When `domain_name` is provided, Terraform creates an ACM certificate with DNS validation. Since Route 53 may live in a different AWS account, the DNS records are **not** created automatically. After `terraform apply`:

1. Copy the `acm_validation_records` output and create those CNAME records in your Route 53 hosted zone
2. Wait for the certificate to validate (check the ACM console or `aws acm describe-certificate`)
3. Create the CNAME from `custom_domain_cname` output to point your domain to CloudFront
4. Run `terraform apply` again — CloudFront will now serve on your custom domain with HTTPS

## WAF

When `enable_waf = true`, the module creates a WAFv2 Web ACL with:

- **AWSManagedRulesCommonRuleSet** — OWASP top 10 protections
- **AWSManagedRulesKnownBadInputsRuleSet** — blocks known bad request patterns
- **AWSManagedRulesAmazonIpReputationList** — blocks requests from malicious IPs

WAF request logs are sent to a CloudWatch log group (`aws-waf-logs-<bucket_name>`) with 30-day retention.

## Examples

Pre-built `.tfvars` files are available in the [`examples/`](examples/) directory:

```bash
terraform apply -var-file="examples/basic.tfvars"
```

### Basic — CloudFront URL only

No custom domain, no WAF, no geo restrictions. Quickest way to get a public status page up.

```hcl
bucket_name              = "my-statuspage"
domain_name              = ""
geo_restriction_type     = "none"
enable_waf               = false
```

### Custom Domain — US only

ACM certificate with DNS validation, whitelisted to US traffic.

```hcl
bucket_name                = "my-statuspage"
domain_name                = "status.example.com"
geo_restriction_type       = "whitelist"
geo_restriction_locations  = ["US"]
enable_waf                 = false
```

### Full Security — custom domain, WAF, geo-restricted

Custom domain, WAF with CloudWatch logging, restricted to US and Canada.

```hcl
bucket_name                = "my-statuspage"
domain_name                = "status.example.com"
geo_restriction_type       = "whitelist"
geo_restriction_locations  = ["US", "CA"]
enable_waf                 = true
```

### Global Access — custom domain, WAF, no geo restrictions

Available worldwide with WAF protection.

```hcl
bucket_name              = "my-statuspage"
domain_name              = "status.example.com"
geo_restriction_type     = "none"
enable_waf               = true
```

## What happens on `terraform apply`

1. Creates (or updates) the S3 bucket with public access blocked
2. Creates a CloudFront distribution with Origin Access Control
3. Optionally provisions an ACM certificate and WAF
4. Runs `npm run build` in the project root
5. Syncs the `dist/` folder to S3
6. Invalidates the CloudFront cache
