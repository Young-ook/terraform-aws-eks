### default values

locals {
  default_helm_config = {
    repository      = "https://charts.helm.sh/stable"
    name            = "metrics-server"
    version         = null
    chart           = "metrics-server"
    namespace       = "kube-system"
    serviceaccount  = "metrics-server"
    cleanup_on_fail = true
    vars            = {}
  }
}
