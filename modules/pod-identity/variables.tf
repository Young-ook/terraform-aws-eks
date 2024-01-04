### security
variable "identities" {
  description = "A configuration list of pod identities"
  validation {
    condition     = var.identities != null && length(var.identities) > 0
    error_message = "Make sure to define valid pod ids configuration."
  }
}

### tags
variable "tags" {
  description = "The key-value maps for tagging"
  type        = map(string)
  default     = {}
}
