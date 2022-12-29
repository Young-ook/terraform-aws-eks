terraform {
  required_providers {
    test = {
      source = "terraform.io/builtin/test"
    }
  }
}

module "main" {
  for_each  = toset(["", "corp"])
  source    = "../.."
  namespace = each.key
}

resource "test_assertions" "pet_name" {
  component = "pet_name"

  check "pet_name" {
    description = "default random pet name"
    condition   = can(regexall("^ecr", module.main[""].name) == 3)
  }
}
