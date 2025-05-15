## Roles for CI/CD in the infrahouse-toolkit repo
module "github-control-github" {
  providers = {
    aws = aws.aws-493370826424-uw1
  }
  source      = "infrahouse/github-role/aws"
  version     = "~> 1.0"
  gh_org_name = "infrahouse8"
  repo_name   = "github-control"
}

resource "aws_iam_role_policy_attachment" "infrahouse-toolkit-github" {
  provider   = aws.aws-493370826424-uw1
  policy_arn = data.aws_iam_policy.administrator-access.arn
  role       = module.github-control-github.github_role_name
}
