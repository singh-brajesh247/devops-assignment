# Exercise the dev module wiring without credentials, a backend, or AWS calls.
mock_provider "aws" {
  alias = "account_a"

  mock_data "aws_ami" {
    defaults = {
      id = "ami-0123456789abcdef0"
    }
  }
}

mock_provider "aws" {
  alias = "account_b"
}

variables {
  bucket_name = "dev-mock-rolec-bucket"
  credential_pgp_keys = {
    engine = "mock-public-key"
    ci     = "mock-public-key"
    alice  = "mock-public-key"
    bob    = "mock-public-key"
  }
}

override_resource {
  target = module.account_a.aws_iam_role.role_a
  values = { arn = "arn:aws:iam::000000000000:role/roleA" }
}

# Keep the cross-account output valid for Account B's exact-ARN validation.
override_resource {
  target = module.account_a.aws_iam_role.role_b
  values = { arn = "arn:aws:iam::000000000000:role/roleB" }
}

override_resource {
  target = module.account_b.aws_iam_role.role_c
  values = { arn = "arn:aws:iam::111111111111:role/roleC" }
}


run "dev_modules_together" {
  command = apply

  assert {
    condition = (
      length(output.instance_ids) == 5 &&
      toset(keys(output.instance_ids)) == toset(keys(var.instances)) &&
      toset(keys(output.private_ips)) == toset(keys(var.instances)) &&
      alltrue([for id in values(output.instance_ids) : id != ""]) &&
      alltrue([for ip in values(output.private_ips) : ip != ""])
    )
    error_message = "Dev must expose IDs and private IPs for all five EC2 instances."
  }

  assert {
    condition = output.role_arns == {
      roleA = "arn:aws:iam::000000000000:role/roleA"
      roleB = "arn:aws:iam::000000000000:role/roleB"
      roleC = "arn:aws:iam::111111111111:role/roleC"
    }
    error_message = "Dev must connect both account modules and expose the three role ARNs."
  }

  assert {
    condition = (
      output.bucket_name == var.bucket_name &&
      toset(keys(output.credentials)) == toset(["engine", "ci", "alice", "bob"]) &&
      output.credentials.engine.encrypted_console_password == null &&
      output.credentials.ci.encrypted_console_password == null &&
      output.credentials.alice.encrypted_console_password != null &&
      output.credentials.bob.encrypted_console_password != null
    )
    error_message = "Dev must expose the target bucket and credentials with console passwords only for alice and bob."
  }
}
