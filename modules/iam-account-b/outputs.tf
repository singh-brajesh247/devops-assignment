output "role_c_arn" {
  value = aws_iam_role.role_c.arn
}

output "bucket_name" {
  value = var.bucket_name
}
