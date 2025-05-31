output "teleport_role_arn" {
  description = "IAM role ARN of a Teleport instance"
  value       = module.instance_profile.instance_role_arn
}
