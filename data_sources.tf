data "aws_caller_identity" "current" {}
data "aws_region" "current" {}

data "aws_iam_policy" "administrator-access" {
  provider = aws.aws-493370826424-uw1
  name     = "AdministratorAccess"
}

data "aws_availability_zones" "uw1" {
  provider = aws.aws-493370826424-uw1
  state    = "available"
}

# InfraHouse Ubuntu Pro AMI (noble), built and published publicly from the CI/CD
# account (303467602807) by infrahouse/infrahouse-ubuntu-pro. Owner-pinned so a
# same-named public AMI from any other account can never be selected.
data "aws_ami" "infrahouse_pro_noble" {
  provider    = aws.aws-493370826424-uw1
  most_recent = true

  filter {
    name = "name"
    values = [
      "infrahouse-ubuntu-pro-noble-*"
    ]
  }

  filter {
    name   = "architecture"
    values = ["x86_64"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  filter {
    name = "state"
    values = [
      "available"
    ]
  }

  owners = ["303467602807"] # InfraHouse
}

data "terraform_remote_state" "cicd" {
  backend = "s3"
  config = {
    bucket = "infrahouse-aws-control-303467602807"
    key    = "terraform.tfstate"
    region = "us-west-1"
    assume_role = {
      role_arn = "arn:aws:iam::289256138624:role/ih-tf-aws-control-303467602807-state-manager-read-only"
    }
  }
}


data "aws_iam_roles" "AWSAdministratorAccess" {
  name_regex = "AWSReservedSSO_AWSAdministratorAccess_.*"
}
