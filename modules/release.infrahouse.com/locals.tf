locals {
  domain_name          = "release.infrahouse.com"
  ih_release_origin_id = "s3-${aws_s3_bucket.infrahouse-release.bucket}"
}
