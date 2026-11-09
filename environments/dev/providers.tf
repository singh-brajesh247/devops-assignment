terraform {
  required_version = ">= 1.14.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  alias               = "account_a"
  region              = "us-east-1"
  profile             = var.account_a_profile
  allowed_account_ids = ["000000000000"]
}

provider "aws" {
  alias               = "account_b"
  region              = "us-east-1"
  profile             = var.account_b_profile
  allowed_account_ids = ["111111111111"]
}
