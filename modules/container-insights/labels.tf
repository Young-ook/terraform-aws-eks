data "aws_partition" "current" {
  count = local.metrics_enabled || local.logs_enabled ? 1 : 0
}

data "aws_region" "current" {
  count = local.metrics_enabled || local.logs_enabled ? 1 : 0
}

resource "random_string" "containerinsights-suffix" {
  count   = local.metrics_enabled || local.logs_enabled ? 1 : 0
  length  = 5
  upper   = false
  lower   = true
  number  = false
  special = false
}

locals {
  suffix = var.petname && (local.metrics_enabled || local.logs_enabled) ? random_string.containerinsights-suffix.0.result : ""
  default-tags = merge(
    { "terraform.io" = "managed" },
  )
}
