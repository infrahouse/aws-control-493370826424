# Default provider
provider "aws" {
  region = "us-west-1"
  assume_role {
    role_arn = local.terraform_admin_role_arn
  }
  default_tags {
    tags = {
      "created_by" : "infrahouse/aws-control-493370826424" # GitHub repository that created a resource
      "environment" : local.environment
    }
  }
}

provider "aws" {
  alias  = "aws-493370826424-uw1"
  region = "us-west-1"
  assume_role {
    role_arn = local.terraform_admin_role_arn
  }
  default_tags {
    tags = {
      "created_by" : "infrahouse/aws-control-493370826424" # GitHub repository that created a resource
      "environment" : local.environment
    }
  }
}

provider "aws" {
  alias  = "aws-493370826424-ue1"
  region = "us-east-1"
  assume_role {
    role_arn = local.terraform_admin_role_arn
  }
  default_tags {
    tags = {
      "created_by" : "infrahouse/aws-control-493370826424" # GitHub repository that created a resource
      "environment" : local.environment
    }
  }
}
