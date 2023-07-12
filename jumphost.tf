resource "aws_key_pair" "aleks" {
  provider   = aws.aws-493370826424-uw1
  key_name   = "aleks"
  public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQDpgAP1z1Lxg9Uv4tam6WdJBcAftZR4ik7RsSr6aNXqfnTj4civrhd/q8qMqF6wL//3OujVDZfhJcffTzPS2XYhUxh/rRVOB3xcqwETppdykD0XZpkHkc8XtmHpiqk6E9iBI4mDwYcDqEg3/vrDAGYYsnFwWmdDinxzMH1Gei+NPTmTqU+wJ1JZvkw3WBEMZKlUVJC/+nuv+jbMmCtm7sIM4rlp2wyzLWYoidRNMK97sG8+v+mDQol/qXK3Fuetj+1f+vSx2obSzpTxL4RYg1kS6W1fBlSvstDV5bQG4HvywzN5Y8eCpwzHLZ1tYtTycZEApFdy+MSfws5vPOpggQlWfZ4vA8ujfWAF75J+WABV4DlSJ3Ng6rLMW78hVatANUnb9s4clOS8H6yAjv+bU3OElKBkQ10wNneoFIMOA3grjPvPp5r8dI0WDXPIznJThDJO5yMCy3OfCXlu38VDQa1sjVj1zAPG+Vn2DsdVrl50hWSYSB17Zww0MYEr8N5rfFE= aleks@MediaPC"
}

module "jumphost" {
  source = "./modules/jumphost"
  providers = {
    aws = aws.aws-493370826424-uw1
  }
  keypair_name = aws_key_pair.aleks.key_name
  subnet_ids   = module.management.subnet_public_ids
}

#data "aws_iam_policy_document" "jumphost_permissions" {
#  provider = aws.aws-493370826424-uw1
#  statement {
#    actions   = ["ec2:Describe*"]
#    resources = ["*"]
#  }
#}
#
#module "jumphost_profile" {
#  source = "./modules/instance_profile"
#  providers = {
#    aws = aws.aws-493370826424-uw1
#  }
#  permissions  = data.aws_iam_policy_document.jumphost_permissions.json
#  profile_name = "jumphost"
#}
#
#resource "aws_instance" "jumphost" {
#  for_each             = toset(module.management.subnet_public_ids)
#  provider             = aws.aws-493370826424-uw1
#  ami                  = data.aws_ami.ubuntu_22.id
#  instance_type        = "t3a.nano"
#  key_name             = aws_key_pair.aleks.key_name
#  subnet_id            = each.key
#  iam_instance_profile = module.jumphost_profile.instance_profile_name
#  tags = {
#    Name : "jumphost-${each.key}"
#  }
#}
#
#output "jumphost_ip_address" {
#  value = [
#    for i in aws_instance.jumphost : i.public_ip
#  ]
#}
