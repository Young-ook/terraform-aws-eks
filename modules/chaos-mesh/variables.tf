### helm
variable "helm" {
  description = "The helm release configuration"
  type        = any
  default = {
    name            = "chaos-mesh"
    repository      = "https://charts.chaos-mesh.org"
    version         = null
    chart           = "chaos-mesh"
    namespace       = "chaos-mesh"
    serviceaccount  = "chaos-mesh-controller"
    cleanup_on_fail = true
    vars            = {}
  }
}

### security/policy
variable "oidc" {
  description = "The Open ID Connect properties"
  type        = map(any)
}

### tags
variable "tags" {
  description = "The key-value maps for tagging"
  type        = map(string)
  default     = {}
}
