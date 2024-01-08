### default values

locals {
  default_pod_identity_config = {
    name           = null
    namespace      = "default"
    serviceaccount = "default"
    eks_name       = "eks"
    role_path      = "/"
    policy_arns    = []
  }
}
