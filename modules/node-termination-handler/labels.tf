resource "random_string" "node-termination-handler-suffix" {
  count   = var.enabled ? 1 : 0
  length  = 5
  upper   = false
  lower   = true
  number  = false
  special = false
}

locals {
  suffix = var.petname && var.enabled ? random_string.node-termination-handler-suffix.0.result : ""
  name   = join("-", compact([var.cluster_name, "app-mesh", local.suffix]))
  default-tags = merge(
    { "terraform.io" = "managed" },
    { "Name" = local.name },
  )
}
