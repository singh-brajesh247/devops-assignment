terraform {
  backend "s3" {
    bucket         = "devopslab"
    key            = "dev/terraform.tfstate"
    region         = "us-east-1"
    encrypt        = true
    dynamodb_table = "dev-terraform-locks"
  }
}
