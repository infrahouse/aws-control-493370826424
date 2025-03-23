## Roles for CI/CD in the osv-scanner repo
module "osv-scanner-github" {
  providers = {
    aws = aws.aws-493370826424-uw1
  }
  source      = "infrahouse/github-role/aws"
  version     = "~> 1.0"
  gh_org_name = "infrahouse"
  repo_name   = "osv-scanner"
}

resource "aws_iam_role_policy_attachment" "osv-scanner-github" {
  provider   = aws.aws-493370826424-uw1
  policy_arn = aws_iam_policy.package-publisher.arn
  role       = module.osv-scanner-github.github_role_name
}
