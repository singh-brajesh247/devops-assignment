mock_provider "aws" {}

variables {
  bucket_name = "assignment-rolec-test"
  role_b_arn  = "arn:aws:iam::000000000000:role/roleB"
}

run "role_c_exact_trust_and_bucket_scope" {
  command = apply

  module {
    source = "../../modules/iam-account-b"
  }

  providers = { aws = aws }

  assert {
    condition = jsondecode(aws_iam_role.role_c.assume_role_policy) == jsondecode(jsonencode({
      Version = "2012-10-17"
      Statement = [{
        Effect    = "Allow"
        Action    = "sts:AssumeRole"
        Principal = { AWS = "arn:aws:iam::000000000000:role/roleB" }
      }]
    }))
    error_message = "roleC must trust only roleB, without account-root or wildcard principals."
  }

  assert {
    condition = jsondecode(aws_iam_role_policy.role_c.policy) == jsondecode(jsonencode({
      Version = "2012-10-17"
      Statement = [{
        Effect   = "Allow"
        Action   = "s3:*"
        Resource = ["arn:aws:s3:::assignment-rolec-test", "arn:aws:s3:::assignment-rolec-test/*"]
      }]
    }))
    error_message = "roleC must grant S3 access only to the named bucket and its objects."
  }
}

run "reject_whole_account_trust" {
  command = plan

  module {
    source = "../../modules/iam-account-b"
  }

  providers = { aws = aws }
  variables {
    role_b_arn = "arn:aws:iam::000000000000:root"
  }
  expect_failures = [var.role_b_arn]
}

run "reject_other_account_a_role" {
  command = plan

  module {
    source = "../../modules/iam-account-b"
  }

  providers = { aws = aws }
  variables {
    role_b_arn = "arn:aws:iam::000000000000:role/roleA"
  }
  expect_failures = [var.role_b_arn]
}
