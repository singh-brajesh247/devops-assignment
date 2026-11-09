variable "bucket_name" {
  description = "Name of the existing Account B S3 bucket that roleC may access."
  type        = string
}

variable "role_b_arn" {
  description = "The exact trusted roleB ARN from Account A."
  type        = string

  validation {
    condition     = var.role_b_arn == "arn:aws:iam::000000000000:role/roleB"
    error_message = "Only roleB in Account A (000000000000) may be trusted."
  }
}
