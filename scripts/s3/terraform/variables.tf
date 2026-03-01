variable "aws_region" {
  description = "AWS region for the S3 bucket and CloudFront distribution"
  type        = string
  default     = "us-east-1"
}

variable "bucket_name" {
  description = "Name of the S3 bucket for the static status page"
  type        = string
  default   = "caledonia-demo-bucket3"
}

variable "aws_profile" {
  description = "AWS CLI profile to use for S3 sync and CloudFront invalidation"
  type        = string
  default     = "cc"
}

variable "domain_name" {
  description = "Custom domain name for the status page (e.g. status.example.com). Leave empty to skip ACM/custom domain setup."
  type        = string
  default     = "demo.caledoniacloud.com"
}

variable "geo_restriction_type" {
  description = "CloudFront geo restriction type: none, whitelist, or blacklist"
  type        = string
  default     = "whitelist"
}

variable "geo_restriction_locations" {
  description = <<-EOT
    List of ISO 3166-1 alpha-2 country codes for the geo restriction.
    Common codes: US (United States), CA (Canada), GB (United Kingdom),
    DE (Germany), FR (France), AU (Australia), JP (Japan), IN (India),
    BR (Brazil), MX (Mexico), IT (Italy), ES (Spain), NL (Netherlands),
    SE (Sweden), NO (Norway), DK (Denmark), FI (Finland), IE (Ireland),
    NZ (New Zealand), SG (Singapore), KR (South Korea), ZA (South Africa),
    CH (Switzerland), AT (Austria), BE (Belgium), PT (Portugal), PL (Poland),
    CZ (Czech Republic), IL (Israel), AE (United Arab Emirates), SA (Saudi Arabia),
    AR (Argentina), CL (Chile), CO (Colombia), TW (Taiwan), HK (Hong Kong),
    MY (Malaysia), TH (Thailand), PH (Philippines), ID (Indonesia), VN (Vietnam).
    Full list: https://www.iso.org/obp/ui/#search/code/
  EOT
  type        = list(string)
  default     = ["US"]
}

variable "enable_waf" {
  description = "Enable AWS WAF on the CloudFront distribution with AWS managed rule groups"
  type        = bool
  default     = true
}

variable "project_root" {
  description = "Path to the statuspage project root relative to this terraform directory"
  type        = string
  default     = "../../.."
}
