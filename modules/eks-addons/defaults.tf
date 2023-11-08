# default variables

locals {
  default_addon_config = {
    name           = "vpc-cni"
    version        = null
    eks_name       = null
    namespace      = "default"
    serviceaccount = null

    # Define how to resolve parameter value conflicts
    resolve_conflicts_on_create = "NONE" # Allowed values: NONE | OVERWRITE
    resolve_conflicts_on_update = "NONE" # Allowed values: NONE | OVERWRITE | PRESERVE
  }
  default_oidc_config = {
    url = ""
    arn = ""
  }
  default_irsa_config = {
    policy_arns = []
  }
}
