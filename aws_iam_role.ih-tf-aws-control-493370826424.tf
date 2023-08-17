## Roles for CI/CD in the aws-control-493370826424 repo

module "ih-tf-aws-control-493370826424-admin" {
  source  = "infrahouse/gha-admin/aws"
  version = "~> 1.0"
  providers = {
    aws = aws.aws-493370826424-uw1
  }
  gh_identity_provider_arn = module.github-connector.gh_openid_connect_provider_arn
  gh_org_name              = "infrahouse"
  repo_name                = "aws-control-493370826424"
  state_bucket             = "infrahouse-aws-control-493370826424"
  admin_allowed_arns = [
    "arn:aws:iam::990466748045:user/aleks"
  ]
}
