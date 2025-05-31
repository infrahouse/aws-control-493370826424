variable "asg_min_size" {
  description = "Minimum number of instances in ASG"
  type        = number
  default     = null
}

variable "asg_max_size" {
  description = "Maximum number of instances in ASG"
  type        = number
  default     = null
}

variable "backend_subnet_ids" {
  description = "Subnets to use for the Teleport server"
  type        = list(string)
}

variable "environment" {
  description = "Name of environment."
  type        = string
}

variable "frontend_subnet_ids" {
  description = "Subnets to use for the Teleport load balancer"
  type        = list(string)
}

variable "force_destroy" {
  description = "Allow deleting data from S3 bucket and DynamoDB table."
  type        = bool
  default     = false
}

variable "github_client_id" {
  description = "GitHub OAuth app client ID. See https://goteleport.com/docs/admin-guides/access-controls/sso/github-sso/#step-14-create-a-github-oauth-app"
  type        = string
}

variable "github_client_secret_secret_name" {
  default = "A secretsmanager secret containing the GitHub OAuth app client secret. See https://goteleport.com/docs/admin-guides/access-controls/sso/github-sso/#step-14-create-a-github-oauth-app"
}

variable "on_demand_base_capacity" {
  description = "If specified, the ASG will request spot instances and this will be the minimal number of on-demand instances."
  type        = number
  default     = null
}

variable "puppet_custom_facts" {
  description = "A map of custom puppet facts"
  type        = any
  default     = {}
}

variable "puppet_debug_logging" {
  description = "Enable debug logging if true."
  type        = bool
  default     = false
}

variable "puppet_environmentpath" {
  description = "A path for directory environments."
  default     = "{root_directory}/environments"
}

variable "puppet_hiera_config_path" {
  description = "Path to hiera configuration file."
  default     = "{root_directory}/environments/{environment}/hiera.yaml"
}

variable "puppet_manifest" {
  description = "Path to puppet manifest. By default ih-puppet will apply {root_directory}/environments/{environment}/manifests/site.pp."
  type        = string
  default     = null
}

variable "puppet_module_path" {
  description = "Path to common puppet modules."
  default     = "{root_directory}/environments/{environment}/modules:{root_directory}/modules"
}

variable "puppet_root_directory" {
  description = "Path where the puppet code is hosted."
  default     = "/opt/puppet-code"
}

variable "teams_to_roles" {
  description = "List of GitHub teams and associated Teleport roles"
  type = list(
    object(
      {
        organization = string
        team         = string
        roles        = list(string)
      }
    )
  )
  default = []
}

variable "ubuntu_codename" {
  description = "Ubuntu version to use for the Teleport server"
  type        = string
  default     = "noble"
}

variable "zone_id" {
  description = "Route53 zone ID to use for the Teleport server"
  type        = string
}
