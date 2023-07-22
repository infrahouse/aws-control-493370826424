terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 4.67"
      configuration_aliases = [
        aws.ue1
      ]
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.5"
    }
  }
}
