## eks addon

resource "aws_eks_addon" "addon" {
  addon_name    = lookup(var.addon_config, "name", local.default_addon_config.name)
  addon_version = lookup(var.addon_config, "version", local.default_addon_config.version)
  cluster_name  = lookup(var.addon_config, "eks_name")
  tags          = var.tags
}
