module "vpn" {
  source  = "registry.infrahouse.com/infrahouse/openvpn/aws"
  version = "~> 0.2"
  providers = {
    aws     = aws
    aws.dns = aws
  }
  backend_subnet_ids         = module.management.subnet_private_ids
  lb_subnet_ids              = module.management.subnet_public_ids
  google_oauth_client_writer = data.aws_iam_role.AWSAdministratorAccess.arn
  zone_id                    = module.infrahouse_com.infrahouse_zone_id
  asg_max_size               = 1
  asg_min_size               = 1
  routes = [
    {
      network : cidrhost(module.management.vpc_cidr_block, 0)
      netmask : cidrnetmask(module.management.vpc_cidr_block)
    }
  ]
}
