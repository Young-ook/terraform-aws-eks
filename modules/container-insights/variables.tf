variable "enabled" {
  description = "A conditional indicator to enable cluster-autoscale"
  type        = bool
  default     = true
}

### helm
variable "helm" {
  description = "The helm release configuration"
  type        = map
  default = {
    name            = "container-insights"
    chart           = "container-insights"
    namespace       = "amazon-cloudwatch"
    serviceaccount  = "aws-container-insights"
    cleanup_on_fail = true
  }
}

### security/policy
variable "oidc" {
  description = "The Open ID Connect properties"
  type        = map
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
