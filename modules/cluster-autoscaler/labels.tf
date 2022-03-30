resource "random_string" "autoscaler-suffix" {
  length  = 5
  upper   = false
  lower   = true
  number  = false
  special = false
}

locals {
  suffix = var.petname ? random_string.autoscaler-suffix.result : ""
  name   = join("-", compact([var.cluster_name, "cluster-autoscaler", local.suffix]))
  default-tags = merge(
    { "terraform.io" = "managed" },
    { "Name" = local.name },
  )
}
