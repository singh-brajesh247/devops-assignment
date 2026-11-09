resource "aws_iam_role" "role_a" {
  name = "roleA"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect    = "Allow"
      Action    = "sts:AssumeRole"
      Principal = { AWS = [for name in sort(tolist(local.console_users)) : aws_iam_user.this[name].arn] }
    }]
  })
}

resource "aws_iam_role_policy" "role_a" {
  name = "administration-except-iam"
  role = aws_iam_role.role_a.name
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      { Effect = "Allow", NotAction = "iam:*", Resource = "*" },
      { Effect = "Deny", Action = "iam:*", Resource = "*" }
    ]
  })
}

resource "aws_iam_role" "role_b" {
  name = "roleB"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect    = "Allow"
      Action    = "sts:AssumeRole"
      Principal = { AWS = [for name in sort(tolist(local.all_users)) : aws_iam_user.this[name].arn] }
    }]
  })
}

# roleB has exactly one permissions policy and one allowed action/resource.
resource "aws_iam_role_policy" "role_b" {
  name = "assume-account-b-roleC-only"
  role = aws_iam_role.role_b.name
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect   = "Allow"
      Action   = "sts:AssumeRole"
      Resource = "arn:aws:iam::111111111111:role/roleC"
    }]
  })
}
