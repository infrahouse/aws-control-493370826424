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
