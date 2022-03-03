variable "enabled" {
  description = "A conditional indicator to enable cluster-autoscale"
  type        = bool
  default     = true
}

### helm
variable "helm" {
  description = "The helm release configuration"
  type        = any
  default = {
    repository      = "https://aws.github.io/eks-charts"
    name            = "aws-load-balancer-controller"
    chart           = "aws-load-balancer-controller"
    namespace       = "kube-system"
    serviceaccount  = "aws-load-balancer-controller"
    cleanup_on_fail = true
    vars            = {}
  }
  validation {
    condition     = var.helm.vars != null
    error_message = "Additional helm variables must not be null."
  }
}

### security/policy
variable "oidc" {
  description = "The Open ID Connect properties"
  type        = map(any)
}

### description
variable "cluster_name" {
  description = "The kubernetes cluster name"
  type        = string
}

variable "petname" {
  description = "An indicator whether to append a random identifier to the end of the name to avoid duplication"
  type        = bool
  default     = true
}

### tags
variable "tags" {
  description = "The key-value maps for tagging"
  type        = map(string)
  default     = {}
}
