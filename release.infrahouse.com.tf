module "release_infrahouse_com" {
  providers = {
    aws     = aws.aws-493370826424-uw1
    aws.ue1 = aws.aws-493370826424-ue1
  }
  source  = "./modules/release.infrahouse.com"
  zone_id = module.infrahouse_com.infrahouse_zone_id
}
