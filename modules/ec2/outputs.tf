output "instance_ids" {
  description = "Instance Name => EC2 instance ID."
  value       = { for name, instance in merge(aws_instance.this, aws_instance.protected) : name => instance.id }
}

output "private_ips" {
  description = "Instance Name => private IPv4 address."
  value       = { for name, instance in merge(aws_instance.this, aws_instance.protected) : name => instance.private_ip }
}
