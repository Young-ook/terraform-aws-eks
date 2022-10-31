### default values

locals {
  default_eks_config = {
    host                   = "localhost"
    token                  = null
    cluster_ca_certificate = null
  }
  default_helm_config = {
    repository      = "https://helm.sh"
    name            = null
    version         = null
    chart           = null
    namespace       = "default"
    serviceaccount  = null
    cleanup_on_fail = true
    vars            = {}
  }
}
