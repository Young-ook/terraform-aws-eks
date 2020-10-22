resource "random_string" "suffix" {
  count   = var.enabled ? 1 : 0
  length  = 12
  upper   = false
  lower   = true
  number  = true
  special = false
}

locals {
  suffix = var.enabled ? random_string.suffix.0.result : ""
  name = var.name == null ? join("-", ["irsa", local.suffix]) : var.name
  default-tags = merge(
    { "terraform.io" = "managed" },
    { "Name" = local.name },
  )
}
