resource "random_string" "irsa-suffix" {
  count   = var.enabled ? 1 : 0
  length  = 12
  upper   = false
  lower   = true
  number  = true
  special = false
}

locals {
  suffix = var.enabled ? random_string.irsa-suffix.0.result : ""
  name   = var.name == null ? substr(join("-", ["irsa", local.suffix]), 0, 64) : substr(var.name, 0, 64)
  default-tags = merge(
    { "terraform.io" = "managed" },
    { "Name" = local.name },
  )
}
