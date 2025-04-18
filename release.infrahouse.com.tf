locals {
  supported_codenames = [
    "focal", "jammy", "noble", "oracular"
  ]
  index_body = file("./files/releases.html")
}
module "release_infrahouse_com" {
  for_each = toset(local.supported_codenames)
  providers = {
    aws     = aws.aws-493370826424-uw1
    aws.ue1 = aws.aws-493370826424-ue1
  }
  source                = "registry.infrahouse.com/infrahouse/debian-repo/aws"
  version               = "~> 2.4"
  bucket_name           = "infrahouse-release-${each.value}"
  repository_codename   = each.value
  package_version_limit = 0
  architectures = [
    "amd64",
    "arm64"
  ]
  domain_name          = "release-${each.value}.infrahouse.com"
  gpg_public_key       = file("./files/DEB-GPG-KEY-infrahouse-${each.value}")
  gpg_sign_with        = "packager-${each.value}@infrahouse.com"
  index_title          = "InfraHouse Releases Repository"
  index_body           = local.index_body
  zone_id              = module.infrahouse_com.infrahouse_zone_id
  bucket_force_destroy = true
  bucket_admin_roles = [
    module.infrahouse-puppet-data-github.github_role_arn,
    module.puppet-code-github.github_role_arn,
    module.infrahouse-toolkit-github.github_role_arn,
    module.osv-scanner-github.github_role_arn,
    aws_iam_role.infrahouse-com-github.arn,
    module.jumphost.jumphost_role_arn,
    local.terraform_admin_role_arn
  ]
  signing_key_readers = [
    module.infrahouse-puppet-data-github.github_role_arn,
    module.puppet-code-github.github_role_arn,
    module.infrahouse-toolkit-github.github_role_arn,
    module.osv-scanner-github.github_role_arn,
    aws_iam_role.infrahouse-com-github.arn,
    module.jumphost.jumphost_role_arn,
  ]
  signing_key_writers = [
    data.aws_iam_role.AWSAdministratorAccess.arn,
  ]
}
