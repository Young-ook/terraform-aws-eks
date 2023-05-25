# Variables for providing to module fixture codes

### network
variable "aws_region" {
  description = "The aws region to deploy"
  type        = string
  default     = "ap-northeast-2"
}

variable "azs" {
  description = "A list of availability zones for the vpc to deploy resources"
  type        = list(string)
  default     = ["ap-northeast-2a", "ap-northeast-2b", "ap-northeast-2c"]
}

### kubernetes
variable "kubernetes_version" {
  description = "The target version of kubernetes"
  type        = string
  default     = "1.24"
}

variable "node_groups" {
  description = "Self mamanged node groups definition"
  default     = []
}

variable "managed_node_groups" {
  description = "Amazon managed node groups definition"
  default     = []
}

variable "fargate_profiles" {
  description = "Amazon Fargate for EKS profiles"
  default     = []
}

### kubeflow
variable "kubeflow_helm_repo" {
  description = "Path to the repository of helm charts to install kubeflow components"
  type        = string
  default     = "./kubeflow-manifests/charts/"
}

### description
variable "name" {
  description = "The logical name of the module instance"
  type        = string
  default     = null
}

### tags
variable "tags" {
  description = "The key-value maps for tagging"
  type        = map(string)
  default     = {}
}
