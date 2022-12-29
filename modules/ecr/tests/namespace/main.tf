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
  name      = "hello"
}

resource "test_assertions" "pet_name" {
  component = "pet_name"

  check "pet_name" {
    description = "default random pet name"
    condition   = can(regexall("^corp", module.main["corp"].name) == 4)
  }
}
