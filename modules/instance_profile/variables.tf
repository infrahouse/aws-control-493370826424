variable "profile_name" {
  description = "Instance profile name."
  type        = string
}

variable "permissions" {
  description = "A JSON with a permissions policy. Note, a new policy will be created with these permissions."
}