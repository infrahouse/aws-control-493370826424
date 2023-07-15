module "infrahouse_com" {
  source = "./modules/infrahouse.com"
  providers = {
    aws = aws.aws-493370826424-uw1
  }
}
