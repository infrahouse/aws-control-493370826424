data "aws_iam_policy_document" "gha-runner" {
  statement {
    actions = [
      "secretsmanager:GetSecretValue"
    ]
    resources = [
      aws_secretsmanager_secret.github_token.arn
    ]
  }
}

resource "aws_iam_policy" "gha-runner" {
  name_prefix = "gha-runner"
  description = "Policy for self-hosted GitHub Actions runner"
  policy      = data.aws_iam_policy_document.gha-runner.json
}
