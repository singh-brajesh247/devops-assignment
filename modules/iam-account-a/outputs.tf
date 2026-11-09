output "role_arns" {
  value = {
    roleA = aws_iam_role.role_a.arn
    roleB = aws_iam_role.role_b.arn
  }
}

output "credentials" {
  description = "Access key IDs and PGP-encrypted secrets/passwords. Decrypt with the corresponding user's private PGP key."
  sensitive   = true
  value = {
    for name in local.all_users : name => {
      access_key_id              = aws_iam_access_key.this[name].id
      encrypted_secret           = aws_iam_access_key.this[name].encrypted_secret
      encrypted_console_password = try(aws_iam_user_login_profile.console[name].encrypted_password, null)
    }
  }
}
