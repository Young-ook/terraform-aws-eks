# Variables for providing to module fixture codes

### network
variable "aws_region" {
  description = "The aws region to deploy"
  type        = string
  default     = "ap-northeast-2"
}

variable "use_default_vpc" {
  description = "A feature flag for whether to use default vpc"
  type        = bool
  default     = true
}

variable "azs" {
  description = "A list of availability zones for the vpc to deploy resources"
  type        = list(string)
  default     = ["ap-northeast-2a", "ap-northeast-2c", "ap-northeast-2d"]
}

### kubernetes cluster
variable "kubernetes_version" {
  description = "The target version of kubernetes"
  type        = string
  default     = "1.27"
}

variable "fargate_profiles" {
  description = "Amazon Fargate for EKS profiles"
  default     = []
}

variable "managed_node_groups" {
  description = "Amazon managed node groups definition"
  default     = []
}

variable "node_groups" {
  description = "Node groups definition"
  default     = []
}

### feature
variable "enable_ssm" {
  description = "Allow ssh access using session manager"
  type        = bool
  default     = false
}

variable "eks_addons" {
  description = "EKS addon(s) definition"
  default     = []
}

variable "helm_addons" {
  description = "Helm addon(s) definition"
  default     = []
}

### description
variable "name" {
  description = "An example name"
  type        = string
  default     = null
}

### tags
variable "tags" {
  description = "The key-value maps for tagging"
  type        = map(string)
  default     = {}
}
