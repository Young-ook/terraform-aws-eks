### kubernetes
variable "eks" {
  description = "EKS cluster context"
  type        = any
}

variable "vpc" {
  description = "VPC context"
  type        = any
}

### tags
variable "tags" {
  description = "The key-value maps for tagging"
  type        = map(string)
  default     = {}
}
