resource "random_string" "irsa-suffix" {
  length  = 12
  upper   = false
  lower   = true
  number  = true
  special = false
}

locals {
  suffix = random_string.irsa-suffix.result
  name   = var.name == null ? substr(join("-", ["irsa", local.suffix]), 0, 64) : substr(var.name, 0, 64)
  default-tags = merge(
    { "terraform.io" = "managed" },
    { "Name" = local.name },
  )
}
