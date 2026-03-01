#!/usr/bin/env bash
set -euo pipefail

# ── Configuration ─────────────────────────────────────────
# Set these values or export them as environment variables before running.
S3_BUCKET="${S3_BUCKET:?Error: S3_BUCKET is not set. Export it or pass it inline.}"
CLOUDFRONT_DISTRIBUTION_ID="${CLOUDFRONT_DISTRIBUTION_ID:-}"
AWS_REGION="${AWS_REGION:-us-east-1}"
# ──────────────────────────────────────────────────────────

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
DIST_DIR="$PROJECT_ROOT/dist"

echo "==> Building site..."
cd "$PROJECT_ROOT"
npm run build

if [ ! -d "$DIST_DIR" ]; then
  echo "Error: Build failed — dist/ directory not found."
  exit 1
fi

echo "==> Uploading to s3://$S3_BUCKET ..."
aws s3 sync "$DIST_DIR" "s3://$S3_BUCKET" \
  --region "$AWS_REGION" \
  --delete \
  --exact-timestamps

echo "==> Upload complete."

if [ -n "$CLOUDFRONT_DISTRIBUTION_ID" ]; then
  echo "==> Invalidating CloudFront distribution $CLOUDFRONT_DISTRIBUTION_ID ..."
  aws cloudfront create-invalidation \
    --distribution-id "$CLOUDFRONT_DISTRIBUTION_ID" \
    --paths "/*" \
    --region "$AWS_REGION" \
    --output text
  echo "==> Invalidation submitted."
else
  echo "==> No CLOUDFRONT_DISTRIBUTION_ID set, skipping cache invalidation."
fi

echo "==> Deploy finished."
