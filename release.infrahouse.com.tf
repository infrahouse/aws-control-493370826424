locals {
  supported_codenames = [
    "focal", "jammy"
  ]
}
module "release_infrahouse_com" {
  for_each = toset(local.supported_codenames)
  providers = {
    aws     = aws.aws-493370826424-uw1
    aws.ue1 = aws.aws-493370826424-ue1
  }
  source               = "infrahouse/debian-repo/aws"
  version              = "2.1.1"
  bucket_name          = "infrahouse-release-${each.value}"
  repository_codename  = each.value
  domain_name          = "release-${each.value}.infrahouse.com"
  gpg_public_key       = file("./files/DEB-GPG-KEY-infrahouse-${each.value}")
  gpg_sign_with        = "packager-${each.value}@infrahouse.com"
  index_title          = "InfraHouse Releases Repository"
  index_body           = "Stay tuned!"
  zone_id              = module.infrahouse_com.infrahouse_zone_id
  bucket_force_destroy = true
  bucket_admin_roles = [
    module.infrahouse-puppet-data-github.github_role_arn,
    module.puppet-code-github.github_role_arn,
    module.infrahouse-toolkit-github.github_role_arn,
    module.jumphost.jumphost_role_arn
  ]
}
