### application
variable "addons" {
  description = "A configuration list of eks addons"
  validation {
    condition     = var.addons != null && length(var.addons) > 0
    error_message = "Make sure to define valid eks addons configuration."
  }
}

### tags
variable "tags" {
  description = "The key-value map for tagging"
  type        = map(string)
  default     = {}
}
