module "github-connector" {
  source = "github.com/infrahouse/terraform-aws-gh-identity-provider"
  providers = {
    aws = aws.aws-493370826424-uw1
  }
}
