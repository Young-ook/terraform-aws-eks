resource "random_string" "lbc-suffix" {
  length  = 5
  upper   = false
  lower   = true
  number  = false
  special = false
}

locals {
  suffix = var.petname ? random_string.lbc-suffix.result : ""
  name   = join("-", compact([var.cluster_name, "aws-load-balancer-controller", local.suffix]))
  default-tags = merge(
    { "terraform.io" = "managed" },
    { "Name" = local.name },
  )
}
