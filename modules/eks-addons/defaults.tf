# default variables

locals {
  default_addon_config = {
    name           = "vpc-cni"
    version        = null
    eks_name       = null
    namespace      = "default"
    serviceaccount = null

    # Define how to resolve parameter value conflicts
    # Allowed values: NONE | OVERWRITE | PRESERVE
    resolve_conflicts = "NONE"
  }
  default_oidc_config = {
    url = ""
    arn = ""
  }
  default_irsa_config = {
    policy_arns = []
  }
}
