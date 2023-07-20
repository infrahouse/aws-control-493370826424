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
    null = {
      source  = "hashicorp/null"
      version = ">= 3.2"
    }
    random = {
      source  = "hashicorp/random"
      version = ">= 3.5"
    }
  }
}
