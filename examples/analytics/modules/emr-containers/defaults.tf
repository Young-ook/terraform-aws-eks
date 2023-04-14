### default variables

module "aws" {
  source = "Young-ook/spinnaker/aws//modules/aws-partitions"
}

locals {
  default_emr_container_provider = {
    type         = "EKS"
    namespace    = "default"
    service_name = "emr-containers"
  }
}
