provider "aws" {
  alias  = "aws-493370826424-uw1"
  region = "us-west-1"
  assume_role {
    role_arn = "arn:aws:iam::493370826424:role/ih-tf-aws-control-493370826424-admin"
  }
  default_tags {
    tags = {
      "created_by" : "infrahouse/aws-control-493370826424" # GitHub repository that created a resource
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
    }
  }
}
