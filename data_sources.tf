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

data "aws_route53_zone" "cicd-ih-com" {
  provider = aws.aws-303467602807-uw1
  zone_id  = data.terraform_remote_state.cicd.outputs.cicd-ih-com-zone-id
}

data "aws_iam_role" "AWSAdministratorAccess" {
  name = "AWSReservedSSO_AWSAdministratorAccess_a84a03e62f490b50"
}
