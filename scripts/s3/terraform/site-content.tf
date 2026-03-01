resource "null_resource" "site_deploy" {
  triggers = {
    always_run = timestamp()
  }

  provisioner "local-exec" {
    working_dir = var.project_root
    command     = <<-EOT
      npm run build && \
      aws s3 sync dist/ s3://${aws_s3_bucket.site.bucket} --delete --profile ${var.aws_profile} && \
      aws cloudfront create-invalidation \
        --distribution-id ${aws_cloudfront_distribution.site.id} \
        --paths "/*" --profile ${var.aws_profile}
    EOT
  }

  depends_on = [
    aws_s3_bucket.site,
    aws_cloudfront_distribution.site,
  ]
}
