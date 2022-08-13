### default values

locals {
  default_helm_config = {
    repository      = "https://prometheus-community.github.io/helm-charts"
    name            = "prometheus"
    version         = null
    chart           = "prometheus"
    namespace       = "prometheus"
    serviceaccount  = "prometheus"
    cleanup_on_fail = true
    vars = {
      "alertmanager.persistentVolume.storageClass" = "gp2"
      "server.persistentVolume.storageClass"       = "gp2"
    }
  }
}
