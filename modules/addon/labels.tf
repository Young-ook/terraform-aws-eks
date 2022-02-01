locals {
  name-tag = { "Name" = lookup(var.addon_config, "name", local.default_addon_config.name) }
  default-tags = merge(
    { "terraform.io" = "managed" },
    local.name-tag
  )
}
