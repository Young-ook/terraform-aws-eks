### default values

locals {
  default_eks_config = {
    ami_type      = "AL2_x86_64"
    instance_type = "t3.medium"
    capacity_type = null # allowed values: ON_DEMAND, SPOT, and default is null
  }
  default_bottlerocket_config = {
    admin_container_enabled      = false
    admin_container_superpowered = false
    admin_container_source       = ""
  }
}
