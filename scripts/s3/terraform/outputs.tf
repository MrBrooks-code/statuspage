output "cloudfront_url" {
  description = "CloudFront distribution domain name"
  value       = aws_cloudfront_distribution.site.domain_name
}

output "s3_bucket_name" {
  description = "Name of the S3 bucket"
  value       = aws_s3_bucket.site.bucket
}

output "cloudfront_distribution_id" {
  description = "CloudFront distribution ID"
  value       = aws_cloudfront_distribution.site.id
}

# --- Custom domain outputs (only populated when domain_name is set) ---

output "acm_certificate_arn" {
  description = "ARN of the ACM certificate (if custom domain is configured)"
  value       = var.domain_name != "" ? aws_acm_certificate.site[0].arn : null
}

output "acm_validation_records" {
  description = "DNS records to create in Route 53 for ACM certificate validation"
  value = var.domain_name != "" ? [
    for dvo in aws_acm_certificate.site[0].domain_validation_options : {
      name  = dvo.resource_record_name
      type  = dvo.resource_record_type
      value = dvo.resource_record_value
    }
  ] : []
}

output "custom_domain_cname" {
  description = "CNAME record to create in Route 53 pointing your domain to CloudFront"
  value = var.domain_name != "" ? {
    name  = var.domain_name
    type  = "CNAME"
    value = aws_cloudfront_distribution.site.domain_name
  } : null
}
