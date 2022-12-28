## eks addon

resource "aws_eks_addon" "addon" {
  for_each      = { for addon in var.addons : addon.name => addon }
  addon_name    = each.key
  addon_version = lookup(each.value, "version", local.default_addon_config["version"])
  cluster_name  = lookup(each.value, "eks_name", local.default_addon_config["eks_name"])
  tags          = merge({ Name = each.key }, var.tags, local.default-tags)
}
