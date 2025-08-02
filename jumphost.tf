module "jumphost" {
  source  = "registry.infrahouse.com/infrahouse/jumphost/aws"
  version = "3.2.1"
  providers = {
    aws = aws.aws-493370826424-uw1
  }
  ubuntu_codename         = "noble"
  subnet_ids              = module.management.subnet_private_ids
  nlb_subnet_ids          = module.management.subnet_public_ids
  environment             = var.environment
  route53_zone_id         = module.infrahouse_com.infrahouse_zone_id
  asg_max_size            = 1
  asg_min_size            = 1
  on_demand_base_capacity = 0
  extra_policies = {
    package-publisher : aws_iam_policy.package-publisher.arn
    jumphost-assume : aws_iam_policy.jumphost-assume.arn
  }
  puppet_hiera_config_path = "/opt/infrahouse-puppet-data/environments/${var.environment}/hiera.yaml"
  packages = [
    "infrahouse-puppet-data"
  ]
}

data "aws_iam_policy_document" "jumphost-assume" {
  statement {
    actions = [
      "sts:AssumeRole"
    ]
    resources = [
      "*"
    ]
  }
}

resource "aws_iam_policy" "jumphost-assume" {
  name_prefix = "jumphost-assume"
  description = "Allow jumphost assume roles"
  policy      = data.aws_iam_policy_document.jumphost-assume.json
}
