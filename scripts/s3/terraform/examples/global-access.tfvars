# Global access — custom domain, WAF enabled, no geo restrictions
# Usage: terraform apply -var-file="examples/global-access.tfvars"

aws_region  = "us-east-1"
aws_profile = "default"
bucket_name = "my-statuspage"

# Custom domain
domain_name = "status.example.com"

# No geo restrictions — accessible worldwide
geo_restriction_type      = "none"
geo_restriction_locations = []

# WAF enabled to protect against malicious traffic
enable_waf = true
