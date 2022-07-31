### default values

locals {
  default_helm_config = {
    repository      = "https://aws.github.io/eks-charts"
    name            = "appmesh-controller"
    version         = null
    chart           = "appmesh-controller"
    namespace       = "aws-appmesh"
    serviceaccount  = "aws-appmesh-controller"
    cleanup_on_fail = true
    vars            = {}
  }
}
