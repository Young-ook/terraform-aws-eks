### frigga name
module "frigga" {
  for_each   = { for k, v in var.identities : k => v }
  source     = "Young-ook/spinnaker/aws//modules/frigga"
  version    = "3.0.0"
  name       = lookup(each.value, "name", null) == null || lookup(each.value, "name", null) == "" ? "pod-identity" : lookup(each.value, "name")
  petname    = true
  max_length = 64
}

locals {
  default-tags = merge(
    { "terraform.io" = "managed" },
  )
}
