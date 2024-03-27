resource "aws_secretsmanager_secret" "runner_token_secret" {
  provider                = aws.aws-493370826424-uw1
  name                    = "runner_token_secret"
  description             = "Token to register a GitHub Actions runner."
  recovery_window_in_days = 0
}

data "aws_iam_policy_document" "github_runner_permissions" {
  statement {
    actions = [
      "secretsmanager:*",
    ]
    resources = [
      aws_secretsmanager_secret.runner_token_secret.arn
    ]
  }
}

resource "aws_iam_policy" "github_runner_permissions" {
  provider    = aws.aws-493370826424-uw1
  name        = "github_runner_permissions"
  description = "Policy that allows to manage github runner token"
  policy      = data.aws_iam_policy_document.github_runner_permissions.json
}
