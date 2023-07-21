data "aws_iam_policy_document" "package-publisher" {
  statement {
    actions = ["s3:*"]
    resources = [
      "${module.release_infrahouse_com.release_bucket_arn}/*"
    ]
  }
}

resource "aws_iam_policy" "package-publisher" {
  provider    = aws.aws-493370826424-uw1
  name        = "package-publisher"
  description = "Policy that allows to publish packages"
  policy      = data.aws_iam_policy_document.package-publisher.json
}