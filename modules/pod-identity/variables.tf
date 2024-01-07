### security
variable "identities" {
  description = "A configuration list of pod identities"
  validation {
    condition     = var.identities != null && length(var.identities) > 0
    error_message = "Make sure to define valid pod identity configuration."
  }
}

### tags
variable "tags" {
  description = "The key-value maps for tagging"
  type        = map(string)
  default     = {}
}
