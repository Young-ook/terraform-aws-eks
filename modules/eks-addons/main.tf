### application/addons
resource "aws_eks_addon" "addon" {
  for_each                 = { for addon in var.addons : addon.name => addon }
  addon_name               = each.key
  addon_version            = lookup(each.value, "version", local.default_addon_config["version"])
  cluster_name             = lookup(each.value, "eks_name", local.default_addon_config["eks_name"])
  service_account_role_arn = lookup(module.irsa, each.key, null) == null ? null : module.irsa[each.key].arn
  resolve_conflicts        = lookup(each.value, "resolve_conflicts", local.default_addon_config["resolve_conflicts"])
  tags                     = merge({ Name = each.key }, local.default-tags, var.tags)
}

### security/policy
module "irsa" {
  for_each       = { for addon in var.addons : addon.name => addon if lookup(addon, "oidc", null) != null }
  source         = "Young-ook/eks/aws//modules/irsa"
  version        = "2.0.1"
  name           = each.key
  namespace      = lookup(each.value, "namespace", local.default_addon_config["namespace"])
  serviceaccount = lookup(each.value, "serviceaccount", local.default_addon_config["serviceaccount"])
  oidc_url       = lookup(lookup(each.value, "oidc", {}), "url", local.default_oidc_config["url"])
  oidc_arn       = lookup(lookup(each.value, "oidc", {}), "arn", local.default_oidc_config["arn"])
  policy_arns    = lookup(each.value, "policy_arns", local.default_irsa_config["policy_arns"])
  tags           = merge(var.tags, local.default-tags, { Name = each.key })
}
