resource "aws_s3_bucket" "infrahouse-release" {
  bucket = "infrahouse-release"
}

resource "aws_s3_bucket_acl" "infrahouse-release" {
  bucket = aws_s3_bucket.infrahouse-release.bucket
  acl    = "public-read"
  depends_on = [
    aws_s3_bucket_public_access_block.infrahouse-release,
    aws_s3_bucket_ownership_controls.infrahouse-release
  ]
}

resource "aws_s3_bucket_public_access_block" "infrahouse-release" {
  bucket                  = aws_s3_bucket.infrahouse-release.bucket
  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
}

resource "aws_s3_bucket_ownership_controls" "infrahouse-release" {
  bucket = aws_s3_bucket.infrahouse-release.bucket
  rule {
    object_ownership = "BucketOwnerPreferred"
  }
}
resource "aws_s3_bucket_website_configuration" "infrahouse-release" {
  bucket = aws_s3_bucket.infrahouse-release.bucket
  index_document {
    suffix = "index.html"
  }
}

resource "aws_s3_object" "index-html" {
  bucket       = aws_s3_bucket.infrahouse-release.bucket
  key          = "index.html"
  source       = "${path.module}/index.html"
  acl          = "public-read"
  content_type = "text/html"
  etag         = filemd5("${path.module}/index.html")
}

resource "aws_s3_bucket" "infrahouse-release-logs" {
  bucket = "infrahouse-release-logs"
}
