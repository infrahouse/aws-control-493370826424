resource "aws_key_pair" "aleks" {
  provider   = aws.aws-493370826424-uw1
  key_name   = "aleks"
  public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQDpgAP1z1Lxg9Uv4tam6WdJBcAftZR4ik7RsSr6aNXqfnTj4civrhd/q8qMqF6wL//3OujVDZfhJcffTzPS2XYhUxh/rRVOB3xcqwETppdykD0XZpkHkc8XtmHpiqk6E9iBI4mDwYcDqEg3/vrDAGYYsnFwWmdDinxzMH1Gei+NPTmTqU+wJ1JZvkw3WBEMZKlUVJC/+nuv+jbMmCtm7sIM4rlp2wyzLWYoidRNMK97sG8+v+mDQol/qXK3Fuetj+1f+vSx2obSzpTxL4RYg1kS6W1fBlSvstDV5bQG4HvywzN5Y8eCpwzHLZ1tYtTycZEApFdy+MSfws5vPOpggQlWfZ4vA8ujfWAF75J+WABV4DlSJ3Ng6rLMW78hVatANUnb9s4clOS8H6yAjv+bU3OElKBkQ10wNneoFIMOA3grjPvPp5r8dI0WDXPIznJThDJO5yMCy3OfCXlu38VDQa1sjVj1zAPG+Vn2DsdVrl50hWSYSB17Zww0MYEr8N5rfFE= aleks@MediaPC"
}

resource "aws_key_pair" "aleks-Black-MBP" {
  provider   = aws.aws-493370826424-uw1
  key_name   = "aleks-Black-MBP"
  public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQDBVMh/uBvxKF88z0VxbFYJwhGJklVWf90HJOiESQetC8AJXx6M0x9faPiK5z/SsFjNerCU9TwUZzEgLudB3OWm/X8BChGH3r1g5MsP3FpCd2UCQGu5/0jdX60TePhQ+4SVuoYpjaKIKhulzKM+lEcsJHIk+pM+cKA9yCt4rWghgp7OLXAJE2cA0qy0vv/DytReHoEPFFFtrKUSltmQhu1ggGXH+5pb7kFx2GWLElhVAeG0d+mJdRUXXnDzqjGvW2IrmOAcKJXkF5m9ITjKn55UiuZIPx4k/iLMQQ+am2F/VlttAdEl8Tgo27Q5UhqAH08sHrVnr1qciS8Rdavt8rNPSseFVh7e3wVvMBH4NvEd2gVPThssxlC7BjIfLQGb1jFiRdMHagbG4U4vtpr2pus2PnmcMOQwdC3WjvmyXHjCRQiS16FwJburRfBKGhQf30wjyzvyJ3PDMk4Sni/3Gl69TKb2s91Zq56yhCCrUjMhTtqjmdNvD8jEmIswV+fTyoU= aleks@Black-MBP"
}

module "jumphost" {
  source = "git::https://github.com/infrahouse/terraform-aws-jumphost.git?ref=2.1.1"
  providers = {
    aws = aws.aws-493370826424-uw1
  }
  keypair_name    = aws_key_pair.aleks.key_name
  ami_id          = "ami-0546f03a1422930ff"
  subnet_ids      = module.management.subnet_private_ids
  nlb_subnet_ids  = module.management.subnet_public_ids
  environment     = var.environment
  route53_zone_id = module.infrahouse_com.infrahouse_zone_id
  extra_policies = {
    (aws_iam_policy.package-publisher.name) : aws_iam_policy.package-publisher.arn
  }
  puppet_hiera_config_path = "/opt/infrahouse-puppet-data/environments/${var.environment}/hiera.yaml"
  packages = [
    "infrahouse-puppet-data"
  ]
  extra_files = [
    {
      content : "export GITHUB_TOKEN=${data.aws_secretsmanager_secret_version.github_token.secret_string}"
      path : "/etc/profile.d/github.sh"
      permissions : "0600"
    }
  ]
}
