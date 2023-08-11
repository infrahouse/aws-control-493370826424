data "aws_iam_policy" "administrator-access" {
  provider = aws.aws-493370826424-uw1
  name     = "AdministratorAccess"
}

data "aws_availability_zones" "uw1" {
  provider = aws.aws-493370826424-uw1
  state    = "available"
}

data "aws_ami" "ubuntu_22" {
  provider    = aws.aws-493370826424-uw1
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-*"]
  }

  filter {
    name   = "architecture"
    values = ["x86_64"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["099720109477"] # Canonical
}

data "terraform_remote_state" "cicd" {
  backend = "s3"
  config = {
    bucket   = "infrahouse-aws-control-303467602807"
    key      = "terraform.tfstate"
    region   = "us-west-1"
    role_arn = "arn:aws:iam::289256138624:role/ih-tf-aws-control-303467602807-state-manager-read-only"
  }
}

data "aws_route53_zone" "cicd-ih-com" {
  provider = aws.aws-303467602807-uw1
  zone_id  = data.terraform_remote_state.cicd.outputs.cicd-ih-com-zone-id
}
