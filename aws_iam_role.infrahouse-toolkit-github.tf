## Roles for CI/CD in the infrahouse-toolkit repo

data "aws_iam_policy_document" "github-assume" {
  statement {
    sid     = "010"
    actions = ["sts:AssumeRoleWithWebIdentity"]
    principals {
      type = "Federated"
      identifiers = [
        module.github-connector.gh_openid_connect_provider_arn
      ]
    }
    condition {
      test     = "StringEquals"
      variable = "token.actions.githubusercontent.com:aud"
      values = [
        "sts.amazonaws.com"
      ]
    }
    condition {
      test     = "StringLike"
      variable = "token.actions.githubusercontent.com:sub"
      values = [
        "repo:infrahouse/infrahouse-toolkit:ref:refs/heads/main"
      ]
    }
  }
}


resource "aws_iam_role" "infrahouse-toolkit-github" {
  provider           = aws.aws-493370826424-uw1
  name               = "infrahouse-toolkit-github"
  description        = "Role for a GitHub Actions runner in a infrahouse-toolkit repo."
  assume_role_policy = data.aws_iam_policy_document.github-assume.json
}

resource "aws_iam_role_policy_attachment" "infrahouse-toolkit-github" {
  provider   = aws.aws-493370826424-uw1
  policy_arn = aws_iam_policy.package-publisher.arn
  role       = aws_iam_role.infrahouse-toolkit-github.name
}
