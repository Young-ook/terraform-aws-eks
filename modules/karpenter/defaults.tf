### default values

locals {
  default_helm_config = {
    repository      = "https://charts.karpenter.sh"
    version         = null
    name            = "karpenter"
    chart           = "karpenter"
    namespace       = "karpenter"
    serviceaccount  = "karpenter"
    cleanup_on_fail = true
    vars            = {}
  }
}
