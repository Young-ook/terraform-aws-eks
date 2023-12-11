### security
variable "namespace" {
  description = "Kubernetes namespace for service account"
  type        = string
  default     = "default"
}

variable "serviceaccount" {
  description = "Kubernetes service account name"
  type        = string
  default     = "default"
}

variable "policy_arns" {
  description = "A list of policy ARNs to attach the role"
  type        = list(string)
  default     = []
}

variable "oidc_url" {
  description = "A URL of the OIDC Provider"
  type        = string
}

variable "oidc_arn" {
  description = "An ARN of the OIDC Provider"
  type        = string
}

### description
variable "name" {
  description = "The logical name of the module instance"
  type        = string
  default     = null
}

variable "path" {
  description = "The path for role"
  type        = string
  default     = "/"
}

### tags
variable "tags" {
  description = "The key-value maps for tagging"
  type        = map(string)
  default     = {}
}
