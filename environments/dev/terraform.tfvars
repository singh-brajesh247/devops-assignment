# Replace subnet/security-group IDs and key names with existing us-east-1 resources.
instances = {
  web = {
    instance_type      = "t3.micro"
    root_volume_type   = "standard"
    root_volume_size   = 16
    key_name           = "dev-web-key"
    subnet_id          = "subnet-0123456789abcdef0"
    security_group_ids = ["sg-0123456789abcdef0"]
    environment        = "dev"
    owner              = "engineering"
  }
  api = {
    instance_type      = "t3.small"
    root_volume_type   = "gp2"
    root_volume_size   = 24
    key_name           = "dev-api-key"
    subnet_id          = "subnet-0123456789abcdef0"
    security_group_ids = ["sg-0123456789abcdef0"]
    environment        = "dev"
    owner              = "engineering"
  }
  worker = {
    instance_type      = "t3.medium"
    root_volume_type   = "gp3"
    root_volume_size   = 32
    key_name           = "dev-worker-key"
    subnet_id          = "subnet-0123456789abcdef0"
    security_group_ids = ["sg-0123456789abcdef0"]
    environment        = "dev"
    owner              = "engineering"
  }
  analytics = {
    instance_type      = "m5.large"
    root_volume_type   = "io1"
    root_volume_size   = 40
    root_iops          = 1000
    key_name           = "dev-analytics-key"
    subnet_id          = "subnet-0123456789abcdef0"
    security_group_ids = ["sg-0123456789abcdef0"]
    environment        = "dev"
    owner              = "engineering"
  }
  database = {
    instance_type      = "r5.large"
    root_volume_type   = "io2"
    root_volume_size   = 48
    root_iops          = 3000
    key_name           = "dev-database-key"
    subnet_id          = "subnet-0123456789abcdef0"
    security_group_ids = ["sg-0123456789abcdef0"]
    environment        = "dev"
    owner              = "engineering"
  }
}
