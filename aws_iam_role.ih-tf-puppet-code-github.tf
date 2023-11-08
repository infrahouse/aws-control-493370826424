## Roles for CI/CD in the puppet-code repo

module "puppet-code-github" {
  providers = {
    aws = aws.aws-493370826424-uw1
  }
  source      = "infrahouse/github-role/aws"
  version     = "~> 1.0"
  gh_org_name = "infrahouse"
  repo_name   = "puppet-code"
}

resource "aws_iam_role_policy_attachment" "puppet-code-github" {
  provider   = aws.aws-493370826424-uw1
  policy_arn = aws_iam_policy.package-publisher.arn
  role       = module.puppet-code-github.github_role_name
}
