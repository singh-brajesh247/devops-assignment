output "instance_ids" {
  description = "Instance Name => EC2 instance ID."
  value       = module.ec2.instance_ids
}

output "private_ips" {
  description = "Instance Name => private IPv4 address."
  value       = module.ec2.private_ips
}

output "role_arns" {
  value = merge(module.account_a.role_arns, { roleC = module.account_b.role_c_arn })
}

output "bucket_name" {
  value = module.account_b.bucket_name
}

output "credentials" {
  sensitive = true
  value     = module.account_a.credentials
}
