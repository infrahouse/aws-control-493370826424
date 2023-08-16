module "github-connector" {
  source  = "infrahouse/gh-identity-provider/aws"
  version = "~> 1.0"
  providers = {
    aws = aws.aws-493370826424-uw1
  }
}
