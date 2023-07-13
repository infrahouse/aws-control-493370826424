terraform {
  backend "s3" {
    bucket         = "infrahouse-aws-control-493370826424"
    key            = "terraform.tfstate"
    region         = "us-west-1"
    role_arn       = "arn:aws:iam::289256138624:role/ih-tf-aws-control-493370826424-state-manager"
    dynamodb_table = "infrahouse-terraform-state-locks"
    encrypt        = true
  }

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 4.67"
    }
  }
}
