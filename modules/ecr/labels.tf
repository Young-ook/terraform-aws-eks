# name and description
resource "random_string" "suffix" {
  length  = 5
  upper   = false
  lower   = true
  number  = false
  special = false
}

locals {
  suffix    = random_string.suffix.result
  name      = join("-", compact([var.namespace, (var.name == "" ? local.suffix : var.name)]))
  repo-name = join("/", compact([var.namespace, (var.name == "" ? local.suffix : var.name)]))
  name-tag  = { "Name" = local.repo-name }
  default-tags = merge(
    { "terraform.io" = "managed" },
    local.name-tag
  )
}
