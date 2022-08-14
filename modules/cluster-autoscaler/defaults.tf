### default values

locals {
  default_helm_config = {
    repository      = join("/", [path.module, "charts"])
    name            = "cluster-autoscaler"
    version         = null
    chart           = "cluster-autoscaler"
    namespace       = "kube-system"
    serviceaccount  = "cluster-autoscaler"
    cleanup_on_fail = true
    vars            = {}
  }
}
