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
  name   = var.name == null ? join("-", ["irsa", local.suffix]) : var.name
  default-tags = merge(
    { "terraform.io" = "managed" },
    { "Name" = local.name },
  )
}
