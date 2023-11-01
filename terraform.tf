terraform {
  backend "s3" {
    bucket         = "infrahouse-aws-control-493370826424"
    key            = "terraform.tfstate"
    region         = "us-west-1"
    dynamodb_table = "infrahouse-terraform-state-locks"
    encrypt        = true
    assume_role = {
      role_arn = "arn:aws:iam::289256138624:role/ih-tf-aws-control-493370826424-state-manager"
    }
  }

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.11"
    }
  }
}
