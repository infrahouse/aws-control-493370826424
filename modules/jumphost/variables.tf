variable "keypair_name" {
  description = "SSH key pair name that will be added to the jumphost instance"
  type        = string
}

variable "ami_id" {
  description = "AMI id for jumphost instances. By default, latest Ubuntu jammy."
  type        = string
  default     = null
}

variable "subnet_ids" {
  description = "List of subnet ids where the jumphost instances will be created"
  type        = list(string)
}
