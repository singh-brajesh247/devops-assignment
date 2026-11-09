module "ec2" {
  source    = "./modules/ec2"
  providers = { aws = aws.account_a }
  instances = var.instances
}

module "account_a" {
  source              = "./modules/iam-account-a"
  providers           = { aws = aws.account_a }
  credential_pgp_keys = var.credential_pgp_keys
}

module "account_b" {
  source      = "./modules/iam-account-b"
  providers   = { aws = aws.account_b }
  bucket_name = var.bucket_name
  # Reference ensures roleB exists before AWS validates roleC's trust principal.
  role_b_arn = module.account_a.role_arns.roleB
}
