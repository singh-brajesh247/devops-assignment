# Uses the dev terraform.tfvars inputs; no AWS API calls are made.
variable "instances" {
  type = any
}

mock_provider "aws" {
  mock_data "aws_ami" {
    defaults = {
      id = "ami-0123456789abcdef0"
    }
  }
}

run "five_distinct_instances" {
  command = apply

  module {
    source = "../../modules/ec2"
  }

  providers = { aws = aws }

  assert {
    condition     = length(aws_instance.this) == 4 && keys(aws_instance.protected) == ["database"]
    error_message = "Exactly four ordinary instances and the protected database must exist."
  }

  assert {
    condition = alltrue([
      for name, instance in merge(aws_instance.this, aws_instance.protected) :
      instance.instance_type == var.instances[name].instance_type &&
      instance.key_name == var.instances[name].key_name &&
      instance.root_block_device[0].volume_type == var.instances[name].root_volume_type &&
      instance.root_block_device[0].volume_size == var.instances[name].root_volume_size &&
      instance.tags.Name == name &&
      instance.tags.Environment == var.instances[name].environment &&
      instance.tags.Owner == var.instances[name].owner
    ])
    error_message = "Every instance must receive its configured type, key pair, root volume, and required tags."
  }

  assert {
    condition = alltrue([
      for name, instance in merge(aws_instance.this, aws_instance.protected) :
      contains(["io1", "io2"], var.instances[name].root_volume_type) ? instance.root_block_device[0].iops == var.instances[name].root_iops : true
    ])
    error_message = "io1 and io2 volumes must receive the requested IOPS."
  }

  assert {
    condition = (
      output.instance_ids == { for name, instance in merge(aws_instance.this, aws_instance.protected) : name => instance.id } &&
      output.private_ips == { for name, instance in merge(aws_instance.this, aws_instance.protected) : name => instance.private_ip }
    )
    error_message = "Outputs must map all five names to their actual resource IDs and private IPs."
  }
}
