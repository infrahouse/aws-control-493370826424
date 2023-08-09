terraform {
  //noinspection HILUnresolvedReference
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 4.67"
    }
    template = {
      source  = "hashicorp/template"
      version = ">= 2.2"
    }
  }
}
