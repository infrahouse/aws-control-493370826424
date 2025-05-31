locals {
  default_module_tags = merge(
    {
      environment : var.environment
      service : "teleport"
      created_by_module : "infrahouse/teleport/aws"
    },
  )

  ami_name_pattern_pro = "ubuntu-pro-server/images/hvm-ssd-gp3/ubuntu-${var.ubuntu_codename}-*"
  cluster_name         = "teleport.${data.aws_route53_zone.selected.name}"
}
