locals {
  cli_users     = toset(["engine", "ci"])
  console_users = toset(["alice", "bob"])
  all_users     = setunion(local.cli_users, local.console_users)
}

resource "aws_iam_user" "this" {
  for_each = local.all_users
  name     = each.key
}

resource "aws_iam_group" "group1" {
  name = "group1"
}

resource "aws_iam_group" "group2" {
  name = "group2"
}

resource "aws_iam_group_membership" "group1" {
  name  = "group1-members"
  group = aws_iam_group.group1.name
  users = [for name in sort(tolist(local.cli_users)) : aws_iam_user.this[name].name]
}

resource "aws_iam_group_membership" "group2" {
  name  = "group2-members"
  group = aws_iam_group.group2.name
  users = [for name in sort(tolist(local.console_users)) : aws_iam_user.this[name].name]
}

resource "aws_iam_access_key" "this" {
  for_each = local.all_users
  user     = aws_iam_user.this[each.key].name
  pgp_key  = var.credential_pgp_keys[each.key]
}

# Only group2 users receive console passwords.
resource "aws_iam_user_login_profile" "console" {
  for_each                = local.console_users
  user                    = aws_iam_user.this[each.key].name
  pgp_key                 = var.credential_pgp_keys[each.key]
  password_length         = 24
  password_reset_required = true
}

resource "aws_iam_group_policy" "group1" {
  name  = "assume-roleB-only"
  group = aws_iam_group.group1.name
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect   = "Allow"
      Action   = "sts:AssumeRole"
      Resource = aws_iam_role.role_b.arn
    }]
  })
}

resource "aws_iam_group_policy" "group2" {
  name  = "assume-roles-and-change-own-password"
  group = aws_iam_group.group2.name
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect   = "Allow"
        Action   = "sts:AssumeRole"
        Resource = [aws_iam_role.role_a.arn, aws_iam_role.role_b.arn]
      },
      {
        Effect   = "Allow"
        Action   = "iam:ChangePassword"
        Resource = "arn:aws:iam::000000000000:user/$${aws:username}"
      },
      {
        Effect   = "Allow"
        Action   = "iam:GetAccountPasswordPolicy"
        Resource = "*"
      }
    ]
  })
}
