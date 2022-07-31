### default values

locals {
  default_helm_config = {
    repository      = "https://charts.chaos-mesh.org"
    name            = "chaos-mesh"
    version         = null
    chart           = "chaos-mesh"
    namespace       = "chaos-mesh"
    serviceaccount  = "chaos-mesh-controller"
    cleanup_on_fail = true
    vars            = {}
  }
}
