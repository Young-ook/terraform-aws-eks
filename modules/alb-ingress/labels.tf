### deprecated
resource "random_string" "albingress-suffix" {
  length  = 5
  upper   = false
  lower   = true
  number  = false
  special = false
}

locals {
  suffix = var.petname ? random_string.albingress-suffix.result : ""
  name   = join("-", compact([var.cluster_name, "alb-ingress", local.suffix]))
  default-tags = merge(
    { "terraform.io" = "managed" },
    { "Name" = local.name },
  )
}
