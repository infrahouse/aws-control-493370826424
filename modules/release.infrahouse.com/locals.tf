locals {
  domain_name          = "release.infrahouse.com"
  ih_release_origin_id = "s3-${aws_s3_bucket.infrahouse-release.bucket}"
  index_html_path      = "${path.module}/files/index.html"
  distributions_path   = "${path.module}/files/distributions"
}
