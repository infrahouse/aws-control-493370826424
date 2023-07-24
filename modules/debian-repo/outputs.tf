output "release_bucket" {
  value = aws_s3_bucket.repo.bucket
}

output "release_bucket_arn" {
  value = aws_s3_bucket.repo.arn
}

output "packager_key_secret_arn" {
  value = aws_secretsmanager_secret.key.arn
}

output "packager_key_secret_id" {
  value = aws_secretsmanager_secret.key.id
}

output "packager_key_passphrase_secret_arn" {
  value = aws_secretsmanager_secret.passphrase.arn
}

output "packager_key_passphrase_secret_id" {
  value = aws_secretsmanager_secret.passphrase.id
}
