variable "extra_policies" {
  description = "A map of additional policy ARNs to attach to the jumphost role"
  type        = map(string)
  default     = {}
}

variable "profile_name" {
  description = "Instance profile name."
  type        = string
}

variable "permissions" {
  description = "A JSON with a permissions policy. Note, a new policy will be created with these permissions."
}
