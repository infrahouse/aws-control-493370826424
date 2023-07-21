output "release_bucket" {
  value = aws_s3_bucket.infrahouse-release.bucket
}

output "release_bucket_arn" {
  value = aws_s3_bucket.infrahouse-release.arn
}
