### kubeflow
variable "kubeflow_helm_repo" {
  description = "Path to the repository of helm charts to install kubeflow components"
  type        = string
  default     = "./"
}

### tags
variable "tags" {
  description = "The key-value maps for tagging"
  type        = map(string)
  default     = {}
}
