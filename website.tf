module "website-vpc" {
  providers = {
    aws = aws.aws-493370826424-uw1
  }
  source                = "infrahouse/service-network/aws"
  version               = "~> 2.0"
  management_cidr_block = "10.0.0.0/22"
  service_name          = "website"
  vpc_cidr_block        = "10.0.4.0/22"
  environment           = var.environment
  subnets = [
    {
      cidr                    = "10.0.4.0/24"
      availability-zone       = data.aws_availability_zones.uw1.names[0]
      map_public_ip_on_launch = true
      create_nat              = true
      forward_to              = ""
    },
    {
      cidr                    = "10.0.5.0/24"
      availability-zone       = data.aws_availability_zones.uw1.names[1]
      map_public_ip_on_launch = true
      create_nat              = true
      forward_to              = ""
    },
    {
      cidr                    = "10.0.6.0/24"
      availability-zone       = data.aws_availability_zones.uw1.names[0]
      map_public_ip_on_launch = false
      create_nat              = false
      forward_to              = "10.0.4.0/24"
    },
    {
      cidr                    = "10.0.7.0/24"
      availability-zone       = data.aws_availability_zones.uw1.names[1]
      map_public_ip_on_launch = false
      create_nat              = false
      forward_to              = "10.0.5.0/24"
    },
  ]
}

module "website" {
  providers = {
    aws = aws.aws-493370826424-uw1
  }
  source                = "infrahouse/website-pod/aws"
  version               = "~> 0.1"
  ami                   = data.aws_ami.ubuntu_22.image_id
  backend_subnets       = module.website-vpc.subnet_private_ids
  dns_zone              = "infrahouse.com"
  internet_gateway_id   = module.website-vpc.internet_gateway_id
  key_pair_name         = aws_key_pair.aleks.key_name
  subnets               = module.website-vpc.subnet_public_ids
  userdata              = module.webserver_userdata.userdata
  webserver_permissions = data.aws_iam_policy_document.webserver_permissions.json
}

module "webserver_userdata" {
  providers = {
    aws = aws.aws-493370826424-uw1
  }
  source         = "./modules/cloud-init-config"
  environment    = var.environment
  gpg_public_key = file("./files/DEB-GPG-KEY-infrahouse-jammy")
  role           = "webserver"
}

data "aws_iam_policy_document" "webserver_permissions" {
  statement {
    actions   = ["ec2:Describe*"]
    resources = ["*"]
  }
}
