### default variables

locals {
  default_emr_container_provider = {
    type      = "EKS"
    namespace = "default"
  }
}