### default values

locals {
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
