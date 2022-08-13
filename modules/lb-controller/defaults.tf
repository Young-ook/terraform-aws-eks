### default values

locals {
  default_helm_config = {
    repository      = "https://aws.github.io/eks-charts"
    name            = "aws-load-balancer-controller"
    version         = null
    chart           = "aws-load-balancer-controller"
    namespace       = "kube-system"
    serviceaccount  = "aws-load-balancer-controller"
    cleanup_on_fail = true
    vars            = {}
  }
}
