data "aws_iam_policy_document" "package-publisher" {

  dynamic "statement" {
    for_each = toset(local.supported_codenames)
    content {
      actions = [
        "s3:ListBucket",
        "s3:GetObject",
        "s3:PutObject",
        "s3:DeleteObject",
      ]
      resources = [
        "${module.release_infrahouse_com[statement.value].release_bucket_arn}/*"
      ]

    }
  }

  dynamic "statement" {
    for_each = toset(local.supported_codenames)
    content {
      actions = [
        "secretsmanager:GetSecretValue"
      ]
      resources = [
        module.release_infrahouse_com[statement.value].packager_key_secret_arn,
        module.release_infrahouse_com[statement.value].packager_key_passphrase_secret_arn
      ]

    }
  }

}

resource "aws_iam_policy" "package-publisher" {
  provider    = aws.aws-493370826424-uw1
  name        = "package-publisher"
  description = "Policy that allows to publish packages"
  policy      = data.aws_iam_policy_document.package-publisher.json
}
