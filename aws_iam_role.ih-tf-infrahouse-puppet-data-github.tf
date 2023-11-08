## Roles for CI/CD in the puppet-code repo

module "infrahouse-puppet-data-github" {
  providers = {
    aws = aws.aws-493370826424-uw1
  }
  source      = "infrahouse/github-role/aws"
  version     = "~> 1.0"
  gh_org_name = "infrahouse"
  repo_name   = "infrahouse-puppet-data"
}

resource "aws_iam_role_policy_attachment" "infrahouse-puppet-data-github" {
  provider   = aws.aws-493370826424-uw1
  policy_arn = aws_iam_policy.package-publisher.arn
  role       = module.infrahouse-puppet-data-github.github_role_name
}
