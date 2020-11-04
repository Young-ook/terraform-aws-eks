resource "random_string" "metrics-suffix" {
  count   = var.enabled ? 1 : 0
  length  = 5
  upper   = false
  lower   = true
  number  = false
  special = false
}

locals {
  suffix = var.petname && var.enabled ? random_string.metrics-suffix.0.result : ""
  name   = join("-", compact([var.cluster_name, "metrics-server", local.suffix]))
  default-tags = merge(
    { "terraform.io" = "managed" },
    { "Name" = local.name },
  )
}
