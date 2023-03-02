### default values

locals {
  default_helm_config = {
    repository       = "https://helm.sh"
    name             = null
    version          = null
    chart            = null
    namespace        = "default"
    serviceaccount   = null
    cleanup_on_fail  = true
    create_namespace = true
    wait             = true
    wait_for_jobs    = false
    values           = {}
  }
  default_oidc_config = {
    url = ""
    arn = ""
  }
  default_irsa_config = {
    policy_arns = []
  }
}
