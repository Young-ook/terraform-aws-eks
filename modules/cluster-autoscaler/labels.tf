resource "random_string" "autoscaler-suffix" {
  count   = var.enabled ? 1 : 0
  length  = 5
  upper   = false
  lower   = true
  number  = false
  special = false
}

locals {
  suffix = var.petname && var.enabled ? random_string.autoscaler-suffix.0.result : ""
  name   = join("-", compact([var.cluster_name, "cluster-autoscaler", local.suffix]))
  default-tags = merge(
    { "terraform.io" = "managed" },
    { "Name" = local.name },
  )
}
