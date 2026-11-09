terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
    }
  }
}

data "aws_ami" "amazon_linux" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["al2023-ami-2023.*-kernel-6.1-x86_64"]
  }

  filter {
    name   = "root-device-type"
    values = ["ebs"]
  }
}

locals {
  instance_tags = {
    for name, instance in var.instances : name => {
      Name        = name
      Environment = instance.environment
      Owner       = instance.owner
    }
  }
}

resource "aws_instance" "this" {
  for_each = { for name, instance in var.instances : name => instance if name != "database" }

  ami                    = coalesce(each.value.ami_id, data.aws_ami.amazon_linux.id)
  instance_type          = each.value.instance_type
  key_name               = each.value.key_name
  subnet_id              = each.value.subnet_id
  vpc_security_group_ids = each.value.security_group_ids
  iam_instance_profile   = each.value.iam_instance_profile

  root_block_device {
    volume_type = each.value.root_volume_type
    volume_size = each.value.root_volume_size
    iops        = each.value.root_iops
    encrypted   = true
    tags        = local.instance_tags[each.key]
  }

  tags = local.instance_tags[each.key]
}

# Lifecycle values must be literals, so the protected entry needs its own block.

resource "aws_instance" "protected" {
  for_each = { for name, instance in var.instances : name => instance if name == "database" }

  ami                    = coalesce(each.value.ami_id, data.aws_ami.amazon_linux.id)
  instance_type          = each.value.instance_type
  key_name               = each.value.key_name
  subnet_id              = each.value.subnet_id
  vpc_security_group_ids = each.value.security_group_ids
  iam_instance_profile   = each.value.iam_instance_profile

  root_block_device {
    volume_type = each.value.root_volume_type
    volume_size = each.value.root_volume_size
    iops        = each.value.root_iops
    encrypted   = true
    tags        = local.instance_tags[each.key]
  }

  tags = local.instance_tags[each.key]

  lifecycle {
    prevent_destroy = true
  }
}
