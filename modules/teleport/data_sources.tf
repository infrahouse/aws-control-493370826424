data "aws_caller_identity" "current" {}
data "aws_region" "current" {}
data "aws_default_tags" "provider" {}

data "aws_ami" "ubuntu_pro" {
  most_recent = true

  filter {
    name   = "name"
    values = [local.ami_name_pattern_pro]
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

  owners = ["099720109477"] # Canonical
}

data "aws_subnet" "backend" {
  id = var.backend_subnet_ids[0]
}

data "aws_subnet" "frontend" {
  id = var.frontend_subnet_ids[0]
}

data "aws_vpc" "selected" {
  id = data.aws_subnet.backend.vpc_id
}

data "aws_route53_zone" "selected" {
  zone_id = var.zone_id
}

data "aws_ami" "selected" {
  filter {
    name = "image-id"
    values = [
      data.aws_ami.ubuntu_pro.id
    ]
  }
}
