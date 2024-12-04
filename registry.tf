module "ecs" {
  source  = "registry.infrahouse.com/infrahouse/ecs/aws"
  version = "3.14.0"
  providers = {
    aws     = aws.aws-493370826424-uw1
    aws.dns = aws.aws-493370826424-uw1
  }
  asg_subnets = module.management.subnet_private_ids
  ami_id      = "ami-0c535e24abbf12738"
  dns_names = [
    "registry"
  ]
  docker_image                          = "pacovk/tapir:0.7.0"
  internet_gateway_id                   = module.management.internet_gateway_id
  load_balancer_subnets                 = module.management.subnet_public_ids
  service_name                          = "terraform-registry"
  ssh_key_name                          = aws_key_pair.aleks-Black-MBP.key_name
  zone_id                               = module.infrahouse_com.infrahouse_zone_id
  asg_max_size                          = 1
  asg_min_size                          = 1
  alb_healthcheck_interval              = 300
  alb_healthcheck_path                  = "/"
  alb_healthcheck_response_code_matcher = "302"
  container_memory                      = "256"
  container_healthcheck_command         = "ls || exit 1"
  task_environment_variables = [
    {
      name : "AUTH_ENDPOINT"
      value : jsondecode(
        data.aws_secretsmanager_secret_version.registry_client_secret.secret_string
      )["auth_uri"]
    },
    {
      name : "AUTH_CLIENT_ID"
      value : jsondecode(
        data.aws_secretsmanager_secret_version.registry_client_secret.secret_string
      )["client_id"]
    },
    {
      name : "AUTH_CLIENT_SECRET"
      value : jsondecode(
        data.aws_secretsmanager_secret_version.registry_client_secret.secret_string
      )["client_secret"]
    },
    {
      name : "AWS_REGION",
      value : data.aws_region.current.name
    },
    {
      name : "STORAGE_CONFIG"
      value : "s3"
    },
    {
      name : "S3_STORAGE_BUCKET_NAME"
      value : aws_s3_bucket.terraform-registry.bucket
    },
    {
      name : "S3_STORAGE_BUCKET_REGION"
      value : aws_s3_bucket.terraform-registry.region
    },
    {
      name : "REGISTRY_HOSTNAME"
      value : "registry.${module.infrahouse_com.infrahouse_zone_name}"
    },
    {
      name : "REGISTRY_PORT"
      value : 443
    }
  ]
  container_command = [
    "-Dquarkus.http.host=0.0.0.0", "-Dquarkus.http.cors=true", "-Dquarkus.http.cors.origins=https://registry.infrahouse.com", "-jar", "/tf/registry/tapir.jar"
  ]
  task_role_arn = aws_iam_role.registry-node.arn
}


resource "aws_secretsmanager_secret" "registry_client_secret" {
  provider                = aws.aws-493370826424-uw1
  name_prefix             = "registry_client_secret"
  description             = "Oauth2 credentials with Google"
  recovery_window_in_days = 0
}

data "aws_secretsmanager_secret_version" "registry_client_secret" {
  provider  = aws.aws-493370826424-uw1
  secret_id = aws_secretsmanager_secret.registry_client_secret.id
}

resource "aws_s3_bucket" "terraform-registry" {
  bucket_prefix = "infrahouse-terraform-registry-"
}

resource "aws_s3_bucket_public_access_block" "terraform-registry" {
  bucket = aws_s3_bucket.terraform-registry.bucket

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}
