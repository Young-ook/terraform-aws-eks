### application
variable "name" {
  description = "The helm addon name"
  type        = string
  validation {
    condition     = var.name != null && var.name != ""
    error_message = "The helm addon name must not be null."
  }
}

variable "chart" {
  description = "The helm addon chart name"
  type        = string
  validation {
    condition     = var.chart != null && var.chart != ""
    error_message = "The helm addon chart name must not be null."
  }
}

variable "chart_version" {
  description = "The helm addon chart version"
  type        = string
  default     = null
}

variable "repository" {
  description = "The helm addon chart name"
  type        = string
  default     = "https://aws.github.io/eks-charts"
}

variable "namespace" {
  description = "A namespace to deploy the helm addon chart"
  type        = string
  default     = "default"
  validation {
    condition     = var.namespace != null && var.namespace != ""
    error_message = "The helm addon namespace must not be null."
  }
}

variable "serviceaccount" {
  description = "A service account for the helm addon chart"
  type        = string
  default     = "default"
  validation {
    condition     = var.serviceaccount != null && var.serviceaccount != ""
    error_message = "The helm addon service account name must not be null."
  }
}

variable "values" {
  description = "Additional configuration values for helm addon chart"
  type        = any
  default     = {}
}

### security
variable "oidc" {
  description = "A map of URL and ARN of the OIDC Provider"
  type        = map(string)
  default = {
    url = ""
    arn = ""
  }
}

### tags
variable "tags" {
  description = "The key-value map for tagging"
  type        = map(string)
  default     = {}
}
