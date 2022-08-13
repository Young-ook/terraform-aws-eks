### default values

locals {
  default_helm_config = {
    repository      = "https://aws.github.io/eks-charts"
    name            = "aws-node-termination-handler"
    version         = null
    chart           = "aws-node-termination-handler"
    namespace       = "kube-system"
    serviceaccount  = "aws-node-termination-handler"
    cleanup_on_fail = true
    vars            = {}
  }
}
