variable "instances" {
  description = "EC2 configurations passed to the module. Provide the five instances required by the assignment."
  type        = any
}

variable "account_a_profile" {
  description = "AWS shared-config profile for the Account A provisioning identity."
  type        = string
  default     = "account-a"
}

variable "account_b_profile" {
  description = "AWS shared-config profile for the Account B provisioning identity."
  type        = string
  default     = "account-b"
}

variable "credential_pgp_keys" {
  description = "Public PGP keys for engine, ci, alice, and bob; validated in the Account A module."
  type        = map(string)
}

variable "bucket_name" {
  description = "Name of the existing S3 bucket in Account B that roleC may access."
  type        = string
}
