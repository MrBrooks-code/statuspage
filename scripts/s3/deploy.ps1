#Requires -Version 5.1
Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

# ── Configuration ─────────────────────────────────────────
# Set these values or pass them as environment variables before running.
if (-not $env:S3_BUCKET) {
    Write-Error "S3_BUCKET is not set. Set it before running: `$env:S3_BUCKET = 'my-bucket'"
    exit 1
}

$S3Bucket = $env:S3_BUCKET
$CloudFrontDistributionId = $env:CLOUDFRONT_DISTRIBUTION_ID
$AwsRegion = if ($env:AWS_REGION) { $env:AWS_REGION } else { "us-east-1" }
# ──────────────────────────────────────────────────────────

$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$ProjectRoot = Resolve-Path (Join-Path $ScriptDir "../..")
$DistDir = Join-Path $ProjectRoot "dist"

Write-Host "==> Building site..."
Push-Location $ProjectRoot
try {
    npm run build
    if ($LASTEXITCODE -ne 0) { throw "Build failed." }
} finally {
    Pop-Location
}

if (-not (Test-Path $DistDir)) {
    Write-Error "Build failed — dist/ directory not found."
    exit 1
}

Write-Host "==> Uploading to s3://$S3Bucket ..."
aws s3 sync $DistDir "s3://$S3Bucket" `
    --region $AwsRegion `
    --delete `
    --exact-timestamps

if ($LASTEXITCODE -ne 0) { throw "S3 upload failed." }
Write-Host "==> Upload complete."

if ($CloudFrontDistributionId) {
    Write-Host "==> Invalidating CloudFront distribution $CloudFrontDistributionId ..."
    aws cloudfront create-invalidation `
        --distribution-id $CloudFrontDistributionId `
        --paths "/*" `
        --region $AwsRegion `
        --output text

    if ($LASTEXITCODE -ne 0) { throw "CloudFront invalidation failed." }
    Write-Host "==> Invalidation submitted."
} else {
    Write-Host "==> No CLOUDFRONT_DISTRIBUTION_ID set, skipping cache invalidation."
}

Write-Host "==> Deploy finished."
