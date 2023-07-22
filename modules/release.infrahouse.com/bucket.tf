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

data "aws_iam_policy_document" "public-access" {
  statement {
    principals {
      type        = "AWS"
      identifiers = ["*"]
    }
    actions = ["s3:GetObject"]
    resources = [
      "${aws_s3_bucket.infrahouse-release.arn}/*"
    ]
  }
}

resource "aws_s3_bucket_policy" "public-access" {
  bucket = aws_s3_bucket.infrahouse-release.bucket
  policy = data.aws_iam_policy_document.public-access.json
}

resource "aws_s3_object" "index-html" {
  bucket       = aws_s3_bucket.infrahouse-release.bucket
  key          = "index.html"
  source       = local.index_html_path
  acl          = "public-read"
  content_type = "text/html"
  etag         = filemd5(local.index_html_path)
}

resource "aws_s3_object" "deb-gpg-key-infrahouse" {
  bucket       = aws_s3_bucket.infrahouse-release.bucket
  key          = "DEB-GPG-KEY-infrahouse"
  source       = local.gpg_key_path
  acl          = "public-read"
  content_type = "text/plain"
  etag         = filemd5(local.gpg_key_path)
}

resource "aws_s3_bucket" "infrahouse-release-logs" {
  bucket = "infrahouse-release-logs"
}

resource "aws_s3_bucket_ownership_controls" "infrahouse-release-logs" {
  bucket = aws_s3_bucket.infrahouse-release-logs.bucket
  rule {
    object_ownership = "BucketOwnerPreferred"
  }
}

resource "aws_s3_bucket_acl" "infrahouse-release-logs" {
  depends_on = [
    aws_s3_bucket_ownership_controls.infrahouse-release
  ]
  bucket = aws_s3_bucket.infrahouse-release-logs.bucket
  acl    = "private"
}
