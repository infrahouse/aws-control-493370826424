resource "aws_s3_object" "distributions" {
  bucket       = aws_s3_bucket.infrahouse-release.bucket
  key          = "conf/distributions"
  source       = local.distributions_path
  content_type = "text/plain"
  etag         = filemd5(local.distributions_path)
}
