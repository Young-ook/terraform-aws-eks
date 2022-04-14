resource "random_string" "node-termination-handler-suffix" {
  length  = 5
  upper   = false
  lower   = true
  number  = false
  special = false
}

locals {
  suffix = var.petname ? random_string.node-termination-handler-suffix.result : ""
  name   = join("-", compact([var.cluster_name, "app-mesh", local.suffix]))
  default-tags = merge(
    { "terraform.io" = "managed" },
    { "Name" = local.name },
  )
}
