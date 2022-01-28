### addon
variable "addon_config" {
  description = "EKS Add-on configuration"
  default     = {}
}

### tags
variable "tags" {
  description = "The key-value maps for tagging"
  type        = map(string)
  default     = {}
}
