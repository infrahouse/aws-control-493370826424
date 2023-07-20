terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 4.67"
      configuration_aliases = [
        aws.ue1
      ]
    }
  }
}
