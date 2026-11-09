# Mocked credential creation never calls AWS or processes real PGP keys.
mock_provider "aws" {}

variables {
  credential_pgp_keys = {
    engine = "mock-public-key"
    ci     = "mock-public-key"
    alice  = "mock-public-key"
    bob    = "mock-public-key"
  }
}

# Stable distinct ARNs let trust assertions detect an omitted or extra user.
override_resource {
  target = aws_iam_user.this["engine"]
  values = { arn = "arn:aws:iam::000000000000:user/engine" }
}

override_resource {
  target = aws_iam_user.this["ci"]
  values = { arn = "arn:aws:iam::000000000000:user/ci" }
}

override_resource {
  target = aws_iam_user.this["alice"]
  values = { arn = "arn:aws:iam::000000000000:user/alice" }
}

override_resource {
  target = aws_iam_user.this["bob"]
  values = { arn = "arn:aws:iam::000000000000:user/bob" }
}

run "account_a_access" {
  command = apply

  module {
    source = "../../modules/iam-account-a"
  }

  providers = { aws = aws }

  assert {
    condition = (
      toset(aws_iam_group_membership.group1.users) == toset(["engine", "ci"]) &&
      toset(aws_iam_group_membership.group2.users) == toset(["alice", "bob"]) &&
      toset(keys(aws_iam_access_key.this)) == toset(["engine", "ci", "alice", "bob"]) &&
      toset(keys(aws_iam_user_login_profile.console)) == toset(["alice", "bob"]) &&
      alltrue([for profile in aws_iam_user_login_profile.console : profile.password_reset_required])
    )
    error_message = "Both groups need CLI keys; only alice and bob may have console profiles, with a required initial password reset."
  }

  assert {
    condition = jsondecode(aws_iam_role_policy.role_a.policy) == jsondecode(jsonencode({
      Version = "2012-10-17"
      Statement = [
        { Effect = "Allow", NotAction = "iam:*", Resource = "*" },
        { Effect = "Deny", Action = "iam:*", Resource = "*" }
      ]
    }))
    error_message = "roleA must allow administration outside IAM and explicitly deny all IAM actions."
  }

  assert {
    condition = jsondecode(aws_iam_role_policy.role_b.policy) == jsondecode(jsonencode({
      Version = "2012-10-17"
      Statement = [{
        Effect   = "Allow"
        Action   = "sts:AssumeRole"
        Resource = "arn:aws:iam::111111111111:role/roleC"
      }]
    }))
    error_message = "roleB's only permission must be sts:AssumeRole on Account B's roleC."
  }

  assert {
    condition = jsondecode(aws_iam_role.role_b.assume_role_policy) == jsondecode(jsonencode({
      Version = "2012-10-17"
      Statement = [{
        Effect = "Allow"
        Action = "sts:AssumeRole"
        Principal = { AWS = [
          "arn:aws:iam::000000000000:user/alice",
          "arn:aws:iam::000000000000:user/bob",
          "arn:aws:iam::000000000000:user/ci",
          "arn:aws:iam::000000000000:user/engine"
        ] }
      }]
    }))
    error_message = "roleB must trust exactly the four named users, including ci."
  }

  assert {
    condition = (
      toset(jsondecode(aws_iam_role.role_a.assume_role_policy).Statement[0].Principal.AWS) == toset([
        "arn:aws:iam::000000000000:user/alice", "arn:aws:iam::000000000000:user/bob"
      ]) &&
      jsondecode(aws_iam_group_policy.group1.policy).Statement[0].Action == "sts:AssumeRole" &&
      jsondecode(aws_iam_group_policy.group1.policy).Statement[0].Resource == aws_iam_role.role_b.arn &&
      toset(jsondecode(aws_iam_group_policy.group2.policy).Statement[0].Resource) == toset([aws_iam_role.role_a.arn, aws_iam_role.role_b.arn]) &&
      jsondecode(aws_iam_group_policy.group2.policy).Statement[1].Action == "iam:ChangePassword" &&
      jsondecode(aws_iam_group_policy.group2.policy).Statement[1].Resource == "arn:aws:iam::000000000000:user/$${aws:username}"
    )
    error_message = "Group assumption permissions and console self-service must match the restricted role trusts."
  }
}
