# Basic deployment — CloudFront URL only, no custom domain, no WAF
# Usage: terraform apply -var-file="examples/basic.tfvars"

aws_region  = "us-east-1"
aws_profile = "default"
bucket_name = "my-statuspage"

# No custom domain
domain_name = ""

# No geo restrictions
geo_restriction_type      = "none"
geo_restriction_locations = []

# WAF disabled
enable_waf = false
