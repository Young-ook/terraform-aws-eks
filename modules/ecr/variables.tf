### security
variable "trusted_accounts" {
  description = "A list of AWS Account IDs you want to allow them access to the ECR repository"
  type        = list(string)
  default     = []
}

variable "image_tag_mutability" {
  description = "The tag mutability setting for the repository. Must be one of: MUTABLE or IMMUTABLE. Defaults to MUTABLE."
  type        = string
  default     = "MUTABLE"
}

variable "scan_on_push" {
  description = "Indicates whether images are scanned after being pushed to the repository (true) or not scanned (false)."
  type        = bool
  default     = false
}

variable "lifecycle_policy" {
  description = "Lifecycle policy JSON document"
  type        = string
  default     = null
}

variable "namespace" {
  description = "Namespace of container image repository"
  type        = string
  default     = ""
}

### description
variable "name" {
  description = "Name of container image repository"
  type        = string
  default     = null
}

### tags
variable "tags" {
  description = "The key-value maps for tagging"
  type        = map(string)
  default     = {}
}
