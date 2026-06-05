## Cross-account role for terraform-aws-secret CMK integration tests.
## The secret-tester role in 303467602807 assumes this role to
## read/write CMK-encrypted secrets created during test runs.

data "aws_iam_policy_document" "secret_consumer_trust" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type = "AWS"
      identifiers = [
        "arn:aws:iam::303467602807:role/secret-tester"
      ]
    }
  }
}

resource "aws_iam_role" "secret_consumer" {
  name               = "secret-consumer"
  assume_role_policy = data.aws_iam_policy_document.secret_consumer_trust.json
}

data "aws_iam_policy_document" "secret_consumer_permissions" {
  statement {
    sid = "SecretRW"
    actions = [
      "secretsmanager:DescribeSecret",
      "secretsmanager:GetSecretValue",
      "secretsmanager:PutSecretValue",
    ]
    resources = [
      "arn:aws:secretsmanager:us-west-1:303467602807:secret:*"
    ]
  }
  statement {
    sid = "UseCmkViaSecretsManager"
    actions = [
      "kms:Decrypt",
      "kms:DescribeKey",
      "kms:Encrypt",
      "kms:GenerateDataKey",
    ]
    resources = ["*"]
    condition {
      test     = "StringEquals"
      variable = "kms:ViaService"
      values = [
        "secretsmanager.us-west-1.amazonaws.com"
      ]
    }
  }
}

resource "aws_iam_policy" "secret_consumer_permissions" {
  name   = "secret-consumer-permissions"
  policy = data.aws_iam_policy_document.secret_consumer_permissions.json
}

resource "aws_iam_role_policy_attachment" "secret_consumer" {
  policy_arn = aws_iam_policy.secret_consumer_permissions.arn
  role       = aws_iam_role.secret_consumer.name
}
