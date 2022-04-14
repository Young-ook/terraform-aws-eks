resource "random_string" "prometheus-suffix" {
  length  = 5
  upper   = false
  lower   = true
  number  = false
  special = false
}

locals {
  suffix = var.petname ? random_string.prometheus-suffix.result : ""
  name   = join("-", compact([var.cluster_name, "prometheus-server", local.suffix]))
  default-tags = merge(
    { "terraform.io" = "managed" },
    { "Name" = local.name },
  )
}
