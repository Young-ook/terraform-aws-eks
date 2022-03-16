resource "random_string" "suffix" {
  length  = 5
  upper   = false
  lower   = true
  number  = false
  special = false
}

locals {
  suffix = var.petname ? random_string.suffix.result : ""
  name   = join("-", compact(["karpenter", local.suffix]))
  default-tags = merge(
    { "terraform.io" = "managed" },
    { "Name" = local.name },
  )
}
