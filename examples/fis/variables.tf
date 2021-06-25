# Variables for providing to module fixture codes

### network
variable "aws_region" {
  description = "The aws region to deploy"
  type        = string
  default     = "us-east-1"
}

variable "cidr" {
  description = "The vpc CIDR (e.g. 10.0.0.0/16)"
  type        = string
  default     = "10.0.0.0/16"
}

variable "azs" {
  description = "A list of availability zones for the vpc to deploy resources"
  type        = list(string)
  default     = ["us-east-1a", "us-east-1b", "us-east-1c"]
}

variable "vpc_endpoint_config" {
  description = "A list of vpc endpoint configurations"
  type        = list
  default     = null
}

variable "private_subnets" {
  description = "A list of CIDRs for private subnets"
  type        = list(string)
  default     = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
}

variable "enable_igw" {
  description = "Should be true if you want to provision Internet Gateway for internet facing communication"
  type        = bool
  default     = true
}

variable "enable_ngw" {
  description = "Should be true if you want to provision NAT Gateway(s) across all of private networks"
  type        = bool
  default     = false
}

variable "single_ngw" {
  description = "Should be true if you want to provision a single shared NAT Gateway across all of private networks"
  type        = bool
  default     = false
}

### kubernetes cluster
variable "kubernetes_version" {
  description = "The target version of kubernetes"
  type        = string
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
