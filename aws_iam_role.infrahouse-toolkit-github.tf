## Roles for CI/CD in the infrahouse-toolkit repo
module "infrahouse-toolkit-github" {
  providers = {
    aws = aws.aws-493370826424-uw1
  }
  source      = "infrahouse/github-role/aws"
  version     = "~> 1.0"
  gh_org_name = "infrahouse"
  repo_name   = "infrahouse-toolkit"
}
