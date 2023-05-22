### application/chart
resource "helm_release" "chart" {
  for_each          = { for addon in var.addons : addon.name => addon }
  name              = each.key
  chart             = lookup(each.value, "chart_name", local.default_helm_config["chart"])
  version           = lookup(each.value, "chart_version", local.default_helm_config["version"])
  repository        = lookup(each.value, "repository", local.default_helm_config["repository"])
  namespace         = lookup(each.value, "namespace", local.default_helm_config["namespace"])
  create_namespace  = lookup(each.value, "create_namespace", local.default_helm_config["create_namespace"])
  cleanup_on_fail   = lookup(each.value, "cleanup_on_fail", local.default_helm_config["cleanup_on_fail"])
  wait              = try(each.value["wait"], local.default_helm_config["wait"])
  wait_for_jobs     = try(each.value["wait_for_jobs"], local.default_helm_config["wait_for_jobs"])
  dependency_update = try(each.value["dependency_update"], local.default_helm_config["dependency_update"])

  dynamic "set" {
    for_each = merge(
      lookup(each.value, "oidc", null) != null ?
      {
        "serviceAccount.name"                                       = lookup(each.value, "serviceaccount", local.default_helm_config["serviceaccount"])
        "serviceAccount.annotations.eks\\.amazonaws\\.com/role-arn" = module.irsa[each.key].arn
      } : {},
    lookup(each.value, "values", local.default_helm_config["values"]))
    content {
      name  = set.key
      value = set.value
    }
  }
}

### security/policy
module "irsa" {
  for_each       = { for addon in var.addons : addon.name => addon if lookup(addon, "oidc", null) != null }
  source         = "Young-ook/eks/aws//modules/iam-role-for-serviceaccount"
  version        = "1.7.10"
  name           = each.key
  namespace      = lookup(each.value, "namespace", local.default_helm_config["namespace"])
  serviceaccount = lookup(each.value, "serviceaccount", local.default_helm_config["serviceaccount"])
  oidc_url       = lookup(lookup(each.value, "oidc", {}), "url", local.default_oidc_config["url"])
  oidc_arn       = lookup(lookup(each.value, "oidc", {}), "arn", local.default_oidc_config["arn"])
  policy_arns    = lookup(each.value, "policy_arns", local.default_irsa_config["policy_arns"])
  tags           = merge(var.tags, local.default-tags, { Name = each.key })
}
