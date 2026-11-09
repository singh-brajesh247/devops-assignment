resource "aws_iam_role" "role_c" {
  name = "roleC"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect    = "Allow"
      Action    = "sts:AssumeRole"
      Principal = { AWS = var.role_b_arn }
    }]
  })
}

resource "aws_iam_role_policy" "role_c" {
  name = "full-access-to-one-bucket"
  role = aws_iam_role.role_c.name
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Action = "s3:*"
      Resource = [
        "arn:aws:s3:::${var.bucket_name}",
        "arn:aws:s3:::${var.bucket_name}/*"
      ]
    }]
  })
}
