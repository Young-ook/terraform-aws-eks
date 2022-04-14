resource "random_string" "metrics-suffix" {
  length  = 5
  upper   = false
  lower   = true
  number  = false
  special = false
}

locals {
  suffix = var.petname ? random_string.metrics-suffix.result : ""
  name   = join("-", compact([var.cluster_name, "metrics-server", local.suffix]))
  default-tags = merge(
    { "terraform.io" = "managed" },
    { "Name" = local.name },
  )
}
