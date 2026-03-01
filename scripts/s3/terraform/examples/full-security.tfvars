# Full security — custom domain, WAF with CloudWatch logging, geo-restricted
# Usage: terraform apply -var-file="examples/full-security.tfvars"

aws_region  = "us-east-1"
aws_profile = "default"
bucket_name = "my-statuspage"

# Custom domain
domain_name = "status.example.com"

# Restrict to US and Canada
geo_restriction_type      = "whitelist"
geo_restriction_locations = ["US", "CA"]

# WAF enabled — managed rule groups + CloudWatch logging
enable_waf = true
