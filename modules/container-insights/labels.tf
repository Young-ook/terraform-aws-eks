data "aws_partition" "current" {
  count = var.enabled ? 1 : 0
}

data "aws_region" "current" {
  count = var.enabled ? 1 : 0
}

resource "random_string" "containerinsights-suffix" {
  count   = var.enabled ? 1 : 0
  length  = 5
  upper   = false
  lower   = true
  number  = false
  special = false
}

locals {
  suffix = var.petname && var.enabled ? random_string.containerinsights-suffix.0.result : ""
  name   = join("-", compact([var.cluster_name, "container-insights", local.suffix]))
  default-tags = merge(
    { "terraform.io" = "managed" },
    { "Name" = local.name },
  )
}
