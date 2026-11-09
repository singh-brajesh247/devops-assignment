variable "instances" {
  description = "EC2 settings keyed by instance name. For this assignment, provide five entries including database. Use existing key pairs, subnets, and security groups."
  type = map(object({
    instance_type        = string
    root_volume_type     = string
    root_volume_size     = number
    root_iops            = optional(number)
    key_name             = string
    subnet_id            = string
    security_group_ids   = set(string)
    environment          = string
    owner                = string
    ami_id               = optional(string)
    iam_instance_profile = optional(string)
  }))
}
