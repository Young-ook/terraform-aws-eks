terraform {
  required_providers {
    test = {
      source = "terraform.io/builtin/test"
    }
  }
}

module "vpc" {
  source  = "Young-ook/vpc/aws"
  version = "1.0.3"
}

module "main" {
  source  = "../.."
  subnets = values(module.vpc.subnets["public"])
  managed_node_groups = [
    {
      name          = "bros"
      instance_type = "t3.small"
      ami_type      = "BOTTLEROCKET_x86_64"
    },
  ]
  node_groups = [
    {
      name          = "bros-arm64"
      instance_type = "m6g.medium"
      ami_type      = "BOTTLEROCKET_ARM_64"
    },
  ]
}

resource "test_assertions" "pet_name" {
  component = "pet_name"

  check "pet_name" {
    description = "default random pet name"
    condition   = can(regex("^eks", module.main.cluster.name))
  }
}
