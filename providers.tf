provider "aws" {
  alias  = "aws-493370826424-uw1"
  region = "us-west-1"
  assume_role {
    role_arn = "arn:aws:iam::493370826424:role/ih-tf-aws-control-493370826424-admin"
  }
  default_tags {
    tags = {
      "created_by" : "infrahouse/aws-control-493370826424" # GitHub repository that created a resource
      "environment" : var.environment
    }
  }
}

provider "aws" {
  alias  = "aws-493370826424-ue1"
  region = "us-east-1"
  assume_role {
    role_arn = "arn:aws:iam::493370826424:role/ih-tf-aws-control-493370826424-admin"
  }
  default_tags {
    tags = {
      "created_by" : "infrahouse/aws-control-493370826424" # GitHub repository that created a resource
      "environment" : var.environment
    }
  }
}

provider "aws" {
  alias  = "aws-303467602807-uw1"
  region = "us-west-1"
  assume_role {
    role_arn = "arn:aws:iam::303467602807:role/ih-tf-aws-control-303467602807-read-only"
  }
}
