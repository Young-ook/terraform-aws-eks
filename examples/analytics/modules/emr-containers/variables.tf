###
variable "container_providers" {
  description = "Configurations for EMR container providers"
  default     = {}
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
