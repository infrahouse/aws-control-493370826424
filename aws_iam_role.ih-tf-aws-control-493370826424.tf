## Roles for CI/CD in the aws-control-493370826424 repo

module "ih-tf-aws-control-493370826424-admin" {
  source = "github.com/infrahouse/terraform-aws-gha-admin"
  providers = {
    aws = aws.aws-493370826424-uw1
  }
  gh_identity_provider_arn = module.github-connector.gh_openid_connect_provider_arn
  repo_name                = "aws-control-493370826424"
  state_bucket             = "infrahouse-aws-control-493370826424"
}
