# Custom domain with ACM certificate, US-only access, no WAF
# Usage: terraform apply -var-file="examples/custom-domain.tfvars"

aws_region  = "us-east-1"
aws_profile = "default"
bucket_name = "my-statuspage"

# Custom domain — creates an ACM cert with DNS validation
# After apply, create the DNS records from the terraform output in your Route 53 hosted zone
domain_name = "status.example.com"

# Restrict to US only
geo_restriction_type      = "whitelist"
geo_restriction_locations = ["US"]

# WAF disabled
enable_waf = false
