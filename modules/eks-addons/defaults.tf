# default variables

locals {
  default_addon_config = {
    name           = "vpc-cni"
    version        = null
    eks_name       = null
    namespace      = "default"
    serviceaccount = null
  }
  default_oidc_config = {
    url = ""
    arn = ""
  }
  default_irsa_config = {
    policy_arns = []
  }
}
